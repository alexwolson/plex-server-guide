# Chapter 21: Verification Checklist

Use this checklist to verify your entire media server setup is working correctly.

## Overview

This chapter provides a systematic way to verify each component of your setup. Work through each section and check off the items.

## Prerequisites

All previous chapters completed.

## Section 1: Docker Services

### Check All Containers Running

```bash
cd ~/mediaserver
docker compose ps
```

**Expected:** All services show "Up" status:

- [ ] nordlynx - Up
- [ ] qbittorrent - Up
- [ ] sonarr - Up
- [ ] radarr - Up
- [ ] prowlarr - Up
- [ ] bazarr - Up (if enabled)
- [ ] jellyseerr - Up (if enabled)
- [ ] caddy - Up
- [ ] ddns-updater - Up

### Check Container Health

```bash
docker compose ps --format "table {{.Name}}\t{{.Status}}"
```

No containers should show "Restarting" or "Exited".

## Section 2: VPN Verification

### Verify VPN Connected

```bash
docker exec nordlynx wg show
```

**Expected:** Shows interface `wg0` with endpoint and handshake.

- [ ] WireGuard interface active

### Verify VPN IP

```bash
docker exec nordlynx curl -s https://ifconfig.io
```

**Expected:** Returns a NordVPN IP (not your home IP).

- [ ] VPN IP is not your home IP

### Verify qBittorrent Uses VPN

```bash
# Get VPN IP
VPN_IP=$(docker exec nordlynx curl -s https://ifconfig.io)
# Get home IP
HOME_IP=$(curl -s https://ifconfig.io)
echo "VPN IP: $VPN_IP"
echo "Home IP: $HOME_IP"
```

- [ ] VPN IP and Home IP are different

## Section 3: Service Web Interfaces

### Local Access

Test each service from your local network:

| Service | URL | Check |
|---------|-----|-------|
| Plex | `http://<server-ip>:32400/web` | [ ] Loads |
| Sonarr | `http://<server-ip>:8989` | [ ] Loads |
| Radarr | `http://<server-ip>:7878` | [ ] Loads |
| Prowlarr | `http://<server-ip>:9696` | [ ] Loads |
| Bazarr | `http://<server-ip>:6767` | [ ] Loads (if enabled) |
| Jellyseerr | `http://<server-ip>:5055` | [ ] Loads (if enabled) |
| qBittorrent | `http://localhost:8080` (via SSH) | [ ] Loads |

### Remote Access (Plex)

Test from outside your network (use phone on cellular):

| Service | URL | Check |
|---------|-----|-------|
| Plex | `https://app.plex.tv` | [ ] Server appears and plays content |

### Remote Access via Domain (Optional - Skip if not using domain)

If you configured a domain and Caddy ([Chapters 14-17](14-domain-and-dns.md)):

| Service | URL | Check |
|---------|-----|-------|
| Jellyseerr | `https://your-domain.com` | [ ] Loads with valid SSL |
| Sonarr | `https://sonarr.your-domain.com` | [ ] Loads with valid SSL |
| Radarr | `https://radarr.your-domain.com` | [ ] Loads with valid SSL |

## Section 4: SSL Certificates (Optional - Skip if not using domain)

If you're using Caddy with a domain:

### Check Certificate Validity

```bash
echo | openssl s_client -connect your-domain.com:443 -servername your-domain.com 2>/dev/null | openssl x509 -noout -dates
```

- [ ] Certificate is valid (not expired)
- [ ] Certificate is from Let's Encrypt

### Check Caddy Logs for Cert Issues

```bash
docker logs caddy 2>&1 | grep -i "certificate\|error"
```

- [ ] No certificate errors

## Section 5: Service Connections

### Prowlarr → Sonarr/Radarr

1. Go to Prowlarr > Settings > Apps
2. Check Sonarr and Radarr status

- [ ] Sonarr shows connected (green)
- [ ] Radarr shows connected (green)

### Indexers Synced

1. Go to Sonarr > Settings > Indexers
2. Verify indexers appear

- [ ] Indexers present in Sonarr
- [ ] Indexers present in Radarr

### Download Client Connected

1. Go to Sonarr > Settings > Download Clients
2. Test qBittorrent connection

- [ ] qBittorrent test successful

Repeat for Radarr.

## Section 6: End-to-End Download Test

### Test Movie Download

1. Go to Radarr
2. Add a movie (something small/old for quick test)
3. Click Search
4. Watch the download progress

- [ ] Radarr finds release
- [ ] Download appears in qBittorrent
- [ ] Download goes through VPN
- [ ] Completed file imports to `/movies`
- [ ] Movie appears in Plex

### Test TV Download

1. Go to Sonarr
2. Add a TV show
3. Search for episodes

- [ ] Sonarr finds episodes
- [ ] Download completes
- [ ] File imports to `/tv`
- [ ] Show appears in Plex

## Section 7: Plex

### Library Scan

```bash
curl -s "http://localhost:32400/library/sections" -H "Accept: application/json"
```

- [ ] Libraries listed (movies, tv)

### Hardware Transcoding

1. Play a video that requires transcoding
2. Check Plex Dashboard

- [ ] Transcode shows "(hw)" for hardware

### Remote Access

1. Go to Plex > Settings > Remote Access

- [ ] Shows "Fully accessible outside your network"

## Section 8: DDNS

### Check Current IP

```bash
docker logs ddns-updater --tail 20
```

- [ ] Shows recent IP check
- [ ] No errors

### Verify DNS Points to Your IP

```bash
dig +short your-domain.com
curl -s https://ifconfig.io
```

- [ ] DNS IP matches your public IP

## Section 9: Security

### SSH Key Authentication

From another computer:
```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no your-username@<server-ip>
```

- [ ] Connection rejected (password auth disabled)

### SSH with Key

```bash
ssh your-username@<server-ip>
```

- [ ] Connection succeeds with key

### fail2ban Status

```bash
sudo fail2ban-client status sshd
```

- [ ] Jail is active
- [ ] Filter is working

### VPN Kill-Switch (if enabled)

```bash
sudo iptables -S DOCKER-USER | grep nordlynx-killswitch
```

- [ ] Kill-switch rules present

## Section 10: Storage

### Check Mount Points

```bash
df -h /data/media
df -h ~/downloads
```

- [ ] Media drive mounted
- [ ] Downloads directory accessible

### Check Permissions

```bash
ls -la /data/media/
ls -la ~/downloads/
```

- [ ] Your user owns the directories
- [ ] Correct permissions (755 or 775)

## Verification Summary

### Critical Items (Must Pass)

- [ ] All Docker containers running
- [ ] VPN working and IP different from home
- [ ] Plex remote access working
- [ ] At least one test download completed successfully

### Optional Items

- [ ] HTTPS working on domain (if configured)
- [ ] Caddy reverse proxy routing correctly (if configured)
- [ ] DDNS keeping IP updated (if configured)
- [ ] Bazarr connected and downloading subtitles
- [ ] Jellyseerr working for requests
- [ ] Kill-switch rules active
- [ ] get-iplayer working (if configured)

## Troubleshooting Failed Checks

If any check fails, refer to the troubleshooting section in the relevant chapter:

| Issue | Chapter |
|-------|---------|
| Container not running | [Chapter 7](07-docker-compose-stack.md) |
| VPN not working | [Chapter 7](07-docker-compose-stack.md), [Appendix A](../appendices/A-nordvpn-wireguard-key.md) |
| Plex remote not working | [Chapter 18](18-plex-remote-access.md) |
| HTTPS not working | [Chapter 16](16-caddy-reverse-proxy.md) (optional) |
| DDNS not updating | [Chapter 17](17-ddns-updater.md) (optional) |
| Downloads not importing | [Chapter 10](10-configure-sonarr.md), [Chapter 11](11-configure-radarr.md) |
| SSH issues | [Chapter 4](04-ssh-security.md) |

## Next Steps

If all checks pass, congratulations! Your media server is fully operational.

Continue to the maintenance chapter for ongoing care of your server.

---

**Previous:** [Chapter 20: get-iplayer (Optional)](20-get-iplayer.md)

**Next:** [Chapter 22: Maintenance](22-maintenance.md)
