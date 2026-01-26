# Chapter 19: VPN Kill-Switch (Optional)

A kill-switch ensures that if your VPN disconnects, no traffic leaks from qBittorrent. This adds an extra layer of protection beyond the container-level isolation.

> **This chapter is optional.** The nordlynx container already provides good isolation. This adds host-level enforcement for extra security.

## Overview

The kill-switch:
- Uses iptables rules at the host level
- Blocks all traffic from the nordlynx container except through the VPN tunnel
- Survives container restarts
- Refreshes automatically every 5 minutes

## Prerequisites

- Docker Compose stack running ([Chapter 7](07-docker-compose-stack.md))
- nordlynx container working with VPN connected
- Basic understanding of what a kill-switch does

## How It Works

The script creates iptables rules that:
1. Allow established connections (VPN handshake replies)
2. Allow UDP port 51820 to the VPN endpoint (WireGuard)
3. Allow DNS queries to the VPN's DNS servers
4. **DROP** all other traffic from the nordlynx container

If the VPN disconnects, qBittorrent traffic is blocked entirely.

## Step 1: Create Scripts Directory

```bash
mkdir -p ~/mediaserver/scripts
```

## Step 2: Create the Kill-Switch Script

Create the script file:

```bash
nano ~/mediaserver/scripts/nordlynx-killswitch.sh
```

Add the following content:

```bash
#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="nordlynx"
NETWORK_NAME="mediaserver_default"
COMMENT_TAG="nordlynx-killswitch"

err() {
  echo "ERROR: $*" >&2
}

if ! command -v docker >/dev/null 2>&1; then
  err "docker not found"
  exit 1
fi

if ! command -v iptables >/dev/null 2>&1; then
  err "iptables not found"
  exit 1
fi

# Resolve bridge interface for the Compose network.
BR_IF="$(docker network inspect "${NETWORK_NAME}" -f '{{index .Options "com.docker.network.bridge.name"}}' 2>/dev/null || true)"
if [[ -z "${BR_IF}" ]]; then
  NET_ID="$(docker network inspect "${NETWORK_NAME}" -f '{{.Id}}' 2>/dev/null || true)"
  if [[ -z "${NET_ID}" ]]; then
    err "network ${NETWORK_NAME} not found"
    exit 1
  fi
  BR_IF="br-${NET_ID:0:12}"
fi

NLX_IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${SERVICE_NAME}" 2>/dev/null || true)"
if [[ -z "${NLX_IP}" ]]; then
  err "container ${SERVICE_NAME} not found or has no IP"
  exit 1
fi

VPN_EP="$(docker exec "${SERVICE_NAME}" wg show 2>/dev/null | awk '/endpoint:/ {print $2}' | cut -d: -f1)"
if [[ -z "${VPN_EP}" ]]; then
  err "VPN endpoint not available (is WireGuard up?)"
  exit 1
fi

DNS_SERVERS="$(docker exec "${SERVICE_NAME}" cat /etc/resolv.conf 2>/dev/null | awk '/^nameserver / {print $2}')"
if [[ -z "${DNS_SERVERS}" ]]; then
  err "no DNS servers found in /etc/resolv.conf"
  exit 1
fi

WAN_IF="$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}')"
if [[ -z "${WAN_IF}" ]]; then
  err "could not determine WAN interface"
  exit 1
fi

# Remove any prior rules with our comment tag.
while read -r rule; do
  [[ -z "${rule}" ]] && continue
  iptables ${rule/-A /-D }
done < <(iptables -S DOCKER-USER | grep "${COMMENT_TAG}" || true)

# Ensure DOCKER-USER exists (Docker creates it, but be defensive).
iptables -S DOCKER-USER >/dev/null 2>&1 || {
  err "DOCKER-USER chain not found; is Docker running?"
  exit 1
}

# 1) Allow established replies.
iptables -I DOCKER-USER 1 -i "${BR_IF}" -s "${NLX_IP}" -m conntrack --ctstate RELATED,ESTABLISHED -m comment --comment "${COMMENT_TAG}" -j ACCEPT
# 2) Allow only WireGuard handshake to VPN endpoint.
iptables -I DOCKER-USER 2 -i "${BR_IF}" -s "${NLX_IP}" -o "${WAN_IF}" -p udp -d "${VPN_EP}" --dport 51820 -m comment --comment "${COMMENT_TAG}" -j ACCEPT
# 3) Allow DNS only to current resolvers.
rule_index=3
for dns_ip in ${DNS_SERVERS}; do
  iptables -I DOCKER-USER ${rule_index} -i "${BR_IF}" -s "${NLX_IP}" -o "${WAN_IF}" -p udp -d "${dns_ip}" --dport 53 -m comment --comment "${COMMENT_TAG}" -j ACCEPT
  rule_index=$((rule_index + 1))
done
# 4) Drop any other egress from nordlynx off the bridge.
iptables -I DOCKER-USER ${rule_index} -i "${BR_IF}" -s "${NLX_IP}" ! -o "${BR_IF}" -m comment --comment "${COMMENT_TAG}" -j DROP

echo "Applied nordlynx kill-switch rules for ${NLX_IP} via ${BR_IF} -> ${VPN_EP} on ${WAN_IF} (DNS: ${DNS_SERVERS})"
```

Save and exit (Ctrl+X, then Y, then Enter).

Make it executable:
```bash
chmod +x ~/mediaserver/scripts/nordlynx-killswitch.sh
```

## Step 3: Create Systemd Service

Create the service file:

```bash
sudo nano /etc/systemd/system/nordlynx-killswitch.service
```

Add the following content (replacing `your-username` with your actual username):

```ini
[Unit]
Description=Nordlynx Kill-Switch (iptables rules)
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStartPre=/bin/bash -c 'for i in {1..60}; do docker exec nordlynx wg show >/dev/null 2>&1 && exit 0; sleep 1; done; exit 1'
ExecStart=/home/your-username/mediaserver/scripts/nordlynx-killswitch.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Save and exit (Ctrl+X, then Y, then Enter).

**Important:** Make sure to replace `your-username` in the `ExecStart` line with your actual username.

## Step 4: Create Systemd Timer

The timer refreshes rules every 5 minutes (handles VPN endpoint changes):

```bash
sudo nano /etc/systemd/system/nordlynx-killswitch.timer
```

Add the following content:

```ini
[Unit]
Description=Refresh nordlynx kill-switch rules periodically

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
```

Save and exit (Ctrl+X, then Y, then Enter).

## Step 5: Enable and Start

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now nordlynx-killswitch.timer
```

## Step 6: Verify Rules Are Applied

Check the service ran successfully:
```bash
sudo systemctl status nordlynx-killswitch.service
```

Check the iptables rules:
```bash
sudo iptables -S DOCKER-USER | grep nordlynx-killswitch
```

You should see several rules with the `nordlynx-killswitch` comment.

## Step 7: Test the Kill-Switch

### Test 1: VPN Down = No Internet

Temporarily disable the VPN:
```bash
sudo docker exec nordlynx wg-quick down wg0
```

Try to access the internet from nordlynx:
```bash
sudo docker exec nordlynx curl -m 5 https://ifconfig.io
```

**Expected:** Connection timeout (traffic blocked).

Try DNS:
```bash
sudo docker exec nordlynx nslookup example.com
```

**Expected:** Failure (DNS blocked when VPN is down).

### Test 2: Restore VPN

Bring VPN back up:
```bash
sudo docker exec nordlynx wg-quick up wg0
```

Verify connectivity:
```bash
sudo docker exec nordlynx curl -s https://ifconfig.io
```

**Expected:** Returns VPN IP address.

## Understanding the Rules

Check current rules:
```bash
sudo iptables -S DOCKER-USER | grep nordlynx-killswitch
```

Example output:
```
-A DOCKER-USER -s 172.18.0.2/32 -i br-abc123 -m conntrack --ctstate RELATED,ESTABLISHED -m comment --comment nordlynx-killswitch -j ACCEPT
-A DOCKER-USER -s 172.18.0.2/32 -d 185.XXX.XXX.XXX/32 -i br-abc123 -o eth0 -p udp --dport 51820 -m comment --comment nordlynx-killswitch -j ACCEPT
-A DOCKER-USER -s 172.18.0.2/32 -d 103.86.96.100/32 -i br-abc123 -o eth0 -p udp --dport 53 -m comment --comment nordlynx-killswitch -j ACCEPT
-A DOCKER-USER -s 172.18.0.2/32 -i br-abc123 ! -o br-abc123 -m comment --comment nordlynx-killswitch -j DROP
```

## Troubleshooting

### Service Fails to Start

1. Check the script path is correct
2. Verify nordlynx is running and VPN is connected
3. Check logs:
   ```bash
   sudo journalctl -u nordlynx-killswitch.service
   ```

### Rules Not Being Applied

1. Run the script manually:
   ```bash
   sudo ~/mediaserver/scripts/nordlynx-killswitch.sh
   ```
2. Check for error messages

### Internet Not Working After Enabling

1. Verify VPN is connected:
   ```bash
   docker exec nordlynx wg show
   ```
2. Restart nordlynx and wait for reconnection:
   ```bash
   docker restart nordlynx
   ```

### How to Disable

To temporarily disable:
```bash
sudo systemctl stop nordlynx-killswitch.timer
```

To remove rules:
```bash
sudo iptables -S DOCKER-USER | grep nordlynx-killswitch | while read rule; do
  sudo iptables ${rule/-A /-D }
done
```

## Quick Reference

| File | Purpose |
|------|---------|
| `~/mediaserver/scripts/nordlynx-killswitch.sh` | Kill-switch script |
| `/etc/systemd/system/nordlynx-killswitch.service` | Systemd service |
| `/etc/systemd/system/nordlynx-killswitch.timer` | 5-minute refresh timer |

## Next Steps

The VPN kill-switch provides extra protection for your downloads. Next is the optional get-iplayer chapter, or skip to the verification checklist.

---

**Previous:** [Chapter 18: Plex Remote Access](18-plex-remote-access.md)

**Next:** [Chapter 20: get-iplayer (Optional)](20-get-iplayer.md)
