# Chapter 8: Configure qBittorrent

qBittorrent is your torrent download client. It receives download requests from Sonarr and Radarr and handles the actual downloading.

## Overview

In this chapter, we'll:
- Access qBittorrent through an SSH tunnel
- Change the default password
- Configure download paths
- Set up categories for Sonarr and Radarr
- Verify VPN connectivity

## Prerequisites

- Docker Compose stack running ([Chapter 7](07-docker-compose-stack.md))
- VPN working (verified in Chapter 7)

## Access qBittorrent

qBittorrent is only accessible from localhost for security. Use an SSH tunnel to access it.

### Create SSH Tunnel

From your local computer:
```bash
ssh -L 8080:localhost:8080 your-username@<server-ip>
```

Keep this terminal open while using qBittorrent.

### Open Web Interface

Open your browser and go to:
```
http://localhost:8080
```

### Get Initial Password

The first time qBittorrent runs, it generates a random password. Find it in the logs:

```bash
docker logs qbittorrent 2>&1 | grep -i "temporary password"
```

You'll see something like:
```
A temporary password is provided for this session: Ab1234xYz
```

### Log In

- Username: `admin`
- Password: (the temporary password from the logs)

## Change the Default Password

1. Click the **gear icon** (Options) in the toolbar
2. Go to **Web UI** tab
3. Under **Authentication**, change the password
4. Click **Save**

> **Important:** Use a strong password. Anyone with access to qBittorrent can download files to your server.

## Configure Download Paths

### Set Default Save Path

1. Go to **Options** (gear icon)
2. Click **Downloads** tab
3. Set **Default Save Path**: `/downloads/complete`
4. Enable **Keep incomplete torrents in**: `/downloads/incomplete`
5. Click **Save**

### Why These Paths?

| Path | Purpose |
|------|---------|
| `/downloads/incomplete` | Where active downloads are stored |
| `/downloads/complete` | Where finished downloads go |

These paths are inside the container. They map to your host directories:
- `/downloads/complete` → `~/downloads/complete`
- `/downloads/incomplete` → `~/downloads/incomplete`

## Configure Connection Settings

### Speed Limits (Optional)

If you want to limit bandwidth:

1. Go to **Options** > **Speed** tab
2. Set upload/download limits as desired
3. Enable **Alternative Rate Limits** for scheduled limiting

## Verify VPN is Working

This is critical - always verify your downloads go through the VPN.

### Method 1: Check IP in qBittorrent

1. Click **View** > **Log**
2. Look for connection messages showing IPs
3. These should be VPN IPs, not your home IP

### Method 2: Command Line Check

On your server:
```bash
# Get VPN IP
docker exec nordlynx curl -s https://ifconfig.io
```

This should show a NordVPN IP address.

```bash
# Get your real IP (for comparison)
curl -s https://ifconfig.io
```

These two IPs should be different.

### Method 3: Download an IP Check Torrent

1. Go to [ipleak.net](https://ipleak.net)
2. Click **Torrent Address detection**
3. Download the magnet link
4. Add it to qBittorrent (using the webUI)
5. The website will show what IP is connecting

This should show a VPN IP, not your home IP.

## Additional Settings

### Disable DHT and PEX (Optional)

For better privacy on private trackers:

1. Go to **Options** > **BitTorrent** tab
2. Disable **Enable DHT** (unless using public trackers)
3. Disable **Enable PEX** (unless using public trackers)

> **Note:** Some public trackers require DHT/PEX. Enable them if downloads aren't starting.

### Queue Settings

1. Go to **Options** > **BitTorrent** tab
2. **Seeding Limits**:
   - Stop seeding when ratio reaches: `1.0`
   - Stop seeding when seeding time reaches: `1440` minutes (24 hours)

This helps maintain good ratios on trackers while not seeding forever.

## Troubleshooting

### Can't Access Web Interface

1. Check qBittorrent is running:
   ```bash
   docker ps | grep qbittorrent
   ```

2. Check SSH tunnel is still open

3. Verify the port mapping:
   ```bash
   docker port nordlynx
   ```
   Should show `127.0.0.1:8080->8080/tcp`

### Downloads Not Starting

1. Check VPN is connected:
   ```bash
   docker exec nordlynx wg show
   ```
   Should show an active WireGuard interface

2. Restart nordlynx:
   ```bash
   docker restart nordlynx
   ```

3. Check for errors:
   ```bash
   docker logs nordlynx --tail 50
   ```

### VPN Shows Your Real IP

If the VPN check shows your home IP:

1. **Stop qBittorrent immediately** - your traffic is exposed
2. Check nordlynx logs:
   ```bash
   docker logs nordlynx
   ```
3. Verify WireGuard key in `.env` is correct
4. Restart the stack:
   ```bash
   cd ~/mediaserver
   docker compose restart nordlynx qbittorrent
   ```

### Permission Issues

If downloads fail with permission errors:

1. Check PUID/PGID match your user:
   ```bash
   id
   ```

2. Verify download directory permissions:
   ```bash
   ls -la ~/downloads/
   ```

3. Fix if needed:
   ```bash
   sudo chown -R $USER:$USER ~/downloads/
   ```

## Quick Reference

| Setting | Value |
|---------|-------|
| Web UI URL | `http://localhost:8080` (via SSH tunnel) |
| Default Username | `admin` |
| Complete Downloads | `/downloads/complete` |
| Incomplete Downloads | `/downloads/incomplete` |
| Sonarr Category | `sonarr` |
| Radarr Category | `radarr` |

## Next Steps

qBittorrent is configured and ready to receive downloads. Next, we'll set up Prowlarr to manage indexers and connect them to Sonarr and Radarr.

---

**Previous:** [Chapter 7: Docker Compose Stack](07-docker-compose-stack.md)

**Next:** [Chapter 9: Configure Prowlarr](09-configure-prowlarr.md)
