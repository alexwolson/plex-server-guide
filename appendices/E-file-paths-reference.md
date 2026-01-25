# Appendix E: File Paths Reference

Quick reference for all important file paths in the media server setup.

## Directory Structure Overview

```
/
├── data/                           # HDD mount point
│   └── media/                      # Media library
│       ├── movies/                 # Movie files
│       ├── tv/                     # TV show files
│       └── homevideo/              # Personal videos
│
├── home/your-username/
│   ├── downloads/                  # SSD - active downloads
│   │   ├── complete/               # Finished downloads
│   │   │   ├── sonarr/             # TV downloads
│   │   │   └── radarr/             # Movie downloads
│   │   └── incomplete/             # In-progress downloads
│   │
│   └── mediaserver/                # SSD - server configuration
│       ├── docker-compose.yml      # Service definitions
│       ├── .env                    # Environment variables (secrets)
│       ├── Caddyfile               # Reverse proxy config
│       ├── config/                 # Service configurations
│       │   ├── sonarr/             # Sonarr config/database
│       │   ├── radarr/             # Radarr config/database
│       │   ├── prowlarr/           # Prowlarr config/database
│       │   ├── bazarr/             # Bazarr config/database
│       │   ├── jellyseerr/         # Jellyseerr config
│       │   ├── qbittorrent/        # qBittorrent config
│       │   └── ddns/               # DDNS updater config
│       ├── caddy/                  # Caddy data
│       │   ├── data/               # SSL certificates
│       │   └── config/             # Caddy config
│       └── scripts/                # Custom scripts
│           └── nordlynx-killswitch.sh
│
├── var/lib/plexmediaserver/        # Plex data
│   └── Library/
│       └── Application Support/
│           └── Plex Media Server/
│               ├── Metadata/       # Media metadata
│               ├── Logs/           # Plex logs
│               └── Preferences.xml # Plex settings
│
└── etc/
    ├── ssh/sshd_config.d/
    │   └── 99-hardened.conf        # SSH hardening
    ├── fail2ban/jail.d/
    │   └── ssh.local               # fail2ban SSH config
    └── systemd/system/
        ├── nordlynx-killswitch.service
        └── nordlynx-killswitch.timer
```

## Host Paths vs Container Paths

Services running in Docker see different paths than the host:

| Type | Host Path | Container Path |
|------|-----------|----------------|
| Media (Movies) | `/data/media/movies` | `/movies` |
| Media (TV) | `/data/media/tv` | `/tv` |
| Downloads | `~/downloads` | `/downloads` |
| Config | `~/mediaserver/config/SERVICE` | `/config` |

### Important!

When configuring services:
- **Use container paths** in service UIs (e.g., `/movies`, `/tv`)
- **Use host paths** in docker-compose.yml volume mounts

## Configuration Files

### Main Configuration

| File | Purpose |
|------|---------|
| `~/mediaserver/docker-compose.yml` | Docker service definitions |
| `~/mediaserver/.env` | Environment variables (contains secrets) |
| `~/mediaserver/Caddyfile` | Reverse proxy configuration |

### Service Configs

| Service | Config Location | Key Files |
|---------|-----------------|-----------|
| Sonarr | `~/mediaserver/config/sonarr/` | `config.xml`, `sonarr.db` |
| Radarr | `~/mediaserver/config/radarr/` | `config.xml`, `radarr.db` |
| Prowlarr | `~/mediaserver/config/prowlarr/` | `config.xml`, `prowlarr.db` |
| Bazarr | `~/mediaserver/config/bazarr/` | `config.yaml`, `db/bazarr.db` |
| Jellyseerr | `~/mediaserver/config/jellyseerr/` | `settings.json`, `db/` |
| qBittorrent | `~/mediaserver/config/qbittorrent/` | `qBittorrent.conf` |
| DDNS | `~/mediaserver/config/ddns/` | `config.json` |

### System Configs

| File | Purpose |
|------|---------|
| `/etc/ssh/sshd_config.d/99-hardened.conf` | SSH security settings |
| `/etc/fail2ban/jail.d/ssh.local` | fail2ban SSH jail |
| `/etc/systemd/system/nordlynx-killswitch.*` | Kill-switch service |

## Log Locations

| Service | Log Location / Command |
|---------|------------------------|
| Docker containers | `docker logs CONTAINER` |
| Plex | `/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Logs/` |
| System | `journalctl -f` |
| SSH auth | `/var/log/auth.log` |
| fail2ban | `fail2ban-client status` |

## Backup Targets

Files to back up regularly:

### Critical (Configs)
```
~/mediaserver/config/
~/mediaserver/.env
~/mediaserver/Caddyfile
~/mediaserver/docker-compose.yml
```

### Important (System Configs)
```
/etc/ssh/sshd_config.d/99-hardened.conf
/etc/fail2ban/jail.d/ssh.local
```

### Large but Replaceable (Plex metadata)
```
/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/
```

## Volume Mounts Reference

From `docker-compose.yml`:

### Sonarr
```yaml
volumes:
  - ${CONFIG_PATH}/sonarr:/config
  - ${MEDIA_PATH}/tv:/tv
  - ${DOWNLOADS_PATH}:/downloads
```

### Radarr
```yaml
volumes:
  - ${CONFIG_PATH}/radarr:/config
  - ${MEDIA_PATH}/movies:/movies
  - ${DOWNLOADS_PATH}:/downloads
```

### qBittorrent
```yaml
volumes:
  - ${CONFIG_PATH}/qbittorrent:/config
  - ${DOWNLOADS_PATH}:/downloads
```

### Caddy
```yaml
volumes:
  - ~/mediaserver/Caddyfile:/etc/caddy/Caddyfile:ro
  - ~/mediaserver/caddy/data:/data
  - ~/mediaserver/caddy/config:/config
```

## Permission Requirements

| Path | Owner | Permissions |
|------|-------|-------------|
| `/data/media/` | `$USER:$USER` | 755 |
| `~/downloads/` | `$USER:$USER` | 755 |
| `~/mediaserver/config/` | `$USER:$USER` | 755 |
| `~/mediaserver/.env` | `$USER:$USER` | 600 |
| Plex data | `plex:plex` | 755 |

## Quick Commands

### Check disk usage
```bash
du -sh /data/media/*
du -sh ~/downloads/*
du -sh ~/mediaserver/config/*
```

### Fix permissions
```bash
sudo chown -R $USER:$USER /data/media
sudo chown -R $USER:$USER ~/downloads
sudo chown -R $USER:$USER ~/mediaserver
```

### Find large files
```bash
find /data/media -type f -size +10G
find ~/downloads -type f -size +5G
```
