# Appendix D: Service Ports Reference

Quick reference for all service ports in the media server stack.

## Port Summary

| Port | Service | Protocol | Exposure |
|------|---------|----------|----------|
| 80 | Caddy (HTTP) | TCP | Public (redirects to 443) |
| 443 | Caddy (HTTPS) | TCP | Public |
| 5055 | Jellyseerr | TCP | LAN / via Caddy |
| 6767 | Bazarr | TCP | LAN only |
| 7878 | Radarr | TCP | LAN / via Caddy |
| 8080 | qBittorrent | TCP | Localhost only |
| 8989 | Sonarr | TCP | LAN / via Caddy |
| 9696 | Prowlarr | TCP | LAN only |
| 32400 | Plex | TCP | Public (direct) |
| 51820 | WireGuard (VPN) | UDP | Outbound only |

## Detailed Port Information

### Public Ports (Internet-Accessible)

These ports are forwarded on your router:

| Port | Service | Purpose |
|------|---------|---------|
| 80 | Caddy | HTTP (Let's Encrypt validation, redirect) |
| 443 | Caddy | HTTPS (secure access to services) |
| 32400 | Plex | Media streaming |

### Internal Ports (LAN Only)

These are accessible only from your local network:

| Port | Service | URL |
|------|---------|-----|
| 5055 | Jellyseerr | `http://server:5055` |
| 6767 | Bazarr | `http://server:6767` |
| 7878 | Radarr | `http://server:7878` |
| 8989 | Sonarr | `http://server:8989` |
| 9696 | Prowlarr | `http://server:9696` |

### Localhost Only

| Port | Service | Access Method |
|------|---------|---------------|
| 8080 | qBittorrent | SSH tunnel required |

Access via:
```bash
ssh -L 8080:localhost:8080 user@server
# Then open http://localhost:8080
```

## Docker Compose Port Mappings

From `docker-compose.yml`:

```yaml
# Caddy - reverse proxy
ports:
  - "80:80"
  - "443:443"

# qBittorrent - localhost only
ports:
  - "127.0.0.1:8080:8080"

# Sonarr
ports:
  - "8989:8989"

# Radarr
ports:
  - "7878:7878"

# Prowlarr
ports:
  - "9696:9696"

# Bazarr
ports:
  - "6767:6767"

# Jellyseerr
ports:
  - "5055:5055"
```

## Internal Docker Communication

Services communicate using container names:

| From | To | Internal URL |
|------|-----|--------------|
| Sonarr | qBittorrent | `http://nordlynx:8080` |
| Radarr | qBittorrent | `http://nordlynx:8080` |
| Prowlarr | Sonarr | `http://sonarr:8989` |
| Prowlarr | Radarr | `http://radarr:7878` |
| Bazarr | Sonarr | `http://sonarr:8989` |
| Bazarr | Radarr | `http://radarr:7878` |
| Caddy | All services | `service-name:port` |

## URL Quick Reference

### Local Network

| Service | URL |
|---------|-----|
| Plex | `http://SERVER_IP:32400/web` |
| Sonarr | `http://SERVER_IP:8989` |
| Radarr | `http://SERVER_IP:7878` |
| Prowlarr | `http://SERVER_IP:9696` |
| Bazarr | `http://SERVER_IP:6767` |
| Jellyseerr | `http://SERVER_IP:5055` |
| qBittorrent | `http://localhost:8080` (via SSH tunnel) |

### Remote (HTTPS)

| Service | URL |
|---------|-----|
| Jellyseerr | `https://your-domain.com` |
| Sonarr | `https://sonarr.your-domain.com` |
| Radarr | `https://radarr.your-domain.com` |
| Plex | `https://app.plex.tv` (or `https://your-domain.com:32400`) |

## Firewall Rules

If using UFW, these rules are needed:

```bash
# Required for remote access
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 32400/tcp # Plex

# Optional: SSH (usually already allowed)
sudo ufw allow 22/tcp
```

## Port Conflicts

If a port is already in use:

```bash
# Find what's using a port
sudo netstat -tlnp | grep :8989
sudo lsof -i :8989

# Kill process (if safe)
sudo kill PID
```

Common conflicts:
- Port 80: Apache/nginx
- Port 443: Apache/nginx
- Port 8080: Other web apps

## Changing Default Ports

To change a service's port, modify `docker-compose.yml`:

```yaml
# Change Sonarr from 8989 to 9999
ports:
  - "9999:8989"  # Host:Container
```

Remember to update Caddy config and any inter-service connections.
