#!/usr/bin/env bash
# Nordlynx VPN Kill-Switch Script
# ================================
#
# This script creates iptables rules that prevent any traffic from the
# nordlynx container from leaving without going through the VPN tunnel.
#
# What it does:
# 1. Allows established connections (VPN handshake replies)
# 2. Allows WireGuard traffic (UDP 51820) to the VPN endpoint
# 3. Allows DNS queries to the VPN's DNS servers
# 4. DROPS all other traffic from the nordlynx container
#
# Installation:
#   1. Copy this script to ~/mediaserver/scripts/
#   2. chmod +x ~/mediaserver/scripts/nordlynx-killswitch.sh
#   3. Copy the .service and .timer files to /etc/systemd/system/
#   4. sudo systemctl daemon-reload
#   5. sudo systemctl enable --now nordlynx-killswitch.timer
#
# The timer runs this script every 5 minutes to handle VPN endpoint changes.

set -euo pipefail

# Configuration
SERVICE_NAME="nordlynx"
NETWORK_NAME="mediaserver_default"
COMMENT_TAG="nordlynx-killswitch"

err() {
  echo "ERROR: $*" >&2
}

# Verify required tools exist
if ! command -v docker >/dev/null 2>&1; then
  err "docker not found"
  exit 1
fi

if ! command -v iptables >/dev/null 2>&1; then
  err "iptables not found"
  exit 1
fi

# Resolve bridge interface for the Compose network
BR_IF="$(docker network inspect "${NETWORK_NAME}" -f '{{index .Options "com.docker.network.bridge.name"}}' 2>/dev/null || true)"
if [[ -z "${BR_IF}" ]]; then
  NET_ID="$(docker network inspect "${NETWORK_NAME}" -f '{{.Id}}' 2>/dev/null || true)"
  if [[ -z "${NET_ID}" ]]; then
    err "network ${NETWORK_NAME} not found"
    exit 1
  fi
  BR_IF="br-${NET_ID:0:12}"
fi

# Get nordlynx container IP
NLX_IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${SERVICE_NAME}" 2>/dev/null || true)"
if [[ -z "${NLX_IP}" ]]; then
  err "container ${SERVICE_NAME} not found or has no IP"
  exit 1
fi

# Get current VPN endpoint
VPN_EP="$(docker exec "${SERVICE_NAME}" wg show 2>/dev/null | awk '/endpoint:/ {print $2}' | cut -d: -f1)"
if [[ -z "${VPN_EP}" ]]; then
  err "VPN endpoint not available (is WireGuard up?)"
  exit 1
fi

# Get DNS servers from container
DNS_SERVERS="$(docker exec "${SERVICE_NAME}" cat /etc/resolv.conf 2>/dev/null | awk '/^nameserver / {print $2}')"
if [[ -z "${DNS_SERVERS}" ]]; then
  err "no DNS servers found in /etc/resolv.conf"
  exit 1
fi

# Determine WAN interface
WAN_IF="$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}')"
if [[ -z "${WAN_IF}" ]]; then
  err "could not determine WAN interface"
  exit 1
fi

# Remove any prior rules with our comment tag
while read -r rule; do
  [[ -z "${rule}" ]] && continue
  iptables ${rule/-A /-D }
done < <(iptables -S DOCKER-USER | grep "${COMMENT_TAG}" || true)

# Ensure DOCKER-USER chain exists
iptables -S DOCKER-USER >/dev/null 2>&1 || {
  err "DOCKER-USER chain not found; is Docker running?"
  exit 1
}

# Apply kill-switch rules

# 1) Allow established replies (for VPN handshake)
iptables -I DOCKER-USER 1 -i "${BR_IF}" -s "${NLX_IP}" -m conntrack --ctstate RELATED,ESTABLISHED -m comment --comment "${COMMENT_TAG}" -j ACCEPT

# 2) Allow WireGuard handshake to VPN endpoint
iptables -I DOCKER-USER 2 -i "${BR_IF}" -s "${NLX_IP}" -o "${WAN_IF}" -p udp -d "${VPN_EP}" --dport 51820 -m comment --comment "${COMMENT_TAG}" -j ACCEPT

# 3) Allow DNS to configured resolvers
rule_index=3
for dns_ip in ${DNS_SERVERS}; do
  iptables -I DOCKER-USER ${rule_index} -i "${BR_IF}" -s "${NLX_IP}" -o "${WAN_IF}" -p udp -d "${dns_ip}" --dport 53 -m comment --comment "${COMMENT_TAG}" -j ACCEPT
  rule_index=$((rule_index + 1))
done

# 4) DROP all other egress from nordlynx off the bridge
iptables -I DOCKER-USER ${rule_index} -i "${BR_IF}" -s "${NLX_IP}" ! -o "${BR_IF}" -m comment --comment "${COMMENT_TAG}" -j DROP

echo "Applied nordlynx kill-switch rules for ${NLX_IP} via ${BR_IF} -> ${VPN_EP} on ${WAN_IF} (DNS: ${DNS_SERVERS})"
