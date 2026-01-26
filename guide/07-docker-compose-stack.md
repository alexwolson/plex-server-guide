# Chapter 7: Docker Compose Stack

In this chapter, we'll deploy all the containerized services using Docker Compose.

## What is Docker?

Docker is a tool that runs applications in isolated **containers**. Think of a container as a lightweight, self-contained package that includes everything an application needs to run—the code, libraries, and dependencies—all bundled together.

**Why use Docker for a media server?**

- **No dependency conflicts**: Each service runs in its own container with its own dependencies. Sonarr can use one version of a library while Radarr uses another—they never interfere with each other.
- **Easy updates**: Updating a service is as simple as pulling a new container image. If an update breaks something, you can instantly roll back.
- **Clean removal**: Removing a service removes everything associated with it. No leftover files scattered across your system.
- **Consistent configuration**: Container configurations are defined in files that can be backed up, shared, and version-controlled.
- **Resource efficiency**: Containers share your system's kernel, using far less overhead than running separate virtual machines.

Without Docker, installing Sonarr, Radarr, Prowlarr, and the other services would require managing Python versions, .NET runtimes, and various dependencies—often leading to conflicts. Docker eliminates this complexity.

## What is Docker Compose?

While Docker runs individual containers, **Docker Compose** orchestrates multiple containers as a unified stack. Instead of running separate `docker run` commands for each service, you define everything in a single `docker-compose.yml` file.

**Benefits of Docker Compose:**

- **Single file configuration**: All your services, their settings, ports, and volumes are defined in one place
- **Simple commands**: `docker compose up -d` starts everything; `docker compose down` stops everything
- **Service networking**: Containers can communicate with each other by name (e.g., Sonarr can reach qBittorrent at `http://qbittorrent:8080`)
- **Dependency management**: You can specify that qBittorrent should only start after the VPN container is running
- **Easy updates**: `docker compose pull && docker compose up -d` updates all services to their latest versions

The `docker-compose.yml` file we'll create defines the entire media server stack. You can version control it, back it up, and use it to recreate your setup on new hardware.

## Overview

We'll start these services:

| Service | Purpose | Port |
|---------|---------|------|
| **nordlynx** | NordVPN WireGuard client | - |
| **qbittorrent** | Torrent download client | 8080 (localhost) |
| **sonarr** | TV show automation | 8989 |
| **radarr** | Movie automation | 7878 |
| **prowlarr** | Indexer management | 9696 |
| **bazarr** | Subtitle automation *(optional)* | 6767 |
| **jellyseerr** | Request management *(optional)* | 5055 |
| **caddy** | Reverse proxy *(optional)* | 80, 443 |
| **ddns-updater** | Dynamic DNS updates *(optional)* | - |

## Choose Your Services

The Docker Compose file below includes all available services, but **you only need to include the ones you want to use**. Here's what each service does:

**Core services** (recommended):
- **nordlynx + qbittorrent**: VPN-protected downloads (required for torrenting)
- **sonarr**: TV show automation
- **radarr**: Movie automation
- **prowlarr**: Manages your indexers and syncs them to Sonarr/Radarr

**Optional services**:
- **bazarr**: Automatic subtitle downloads—skip if you don't need subtitles
- **jellyseerr**: Lets others request content—skip if you're the only user
- **caddy**: Reverse proxy for HTTPS access—only needed if you want domain-based URLs (see [Part 3](14-domain-and-dns.md))
- **ddns-updater**: Keeps your domain pointed at your IP—only needed with Caddy and a dynamic IP

**To remove a service you don't need:** Simply delete that service's entire block from `docker-compose.yml` before running `docker compose up`. For example, if you don't want Bazarr, delete everything from `bazarr:` down to (but not including) the next service definition.

## Prerequisites

- Docker installed ([Chapter 3](03-install-docker.md))
- Storage configured ([Chapter 5](05-storage-setup.md))
- Plex installed ([Chapter 6](06-install-plex.md))
- NordVPN WireGuard private key (see [Appendix A](../appendices/A-nordvpn-wireguard-key.md))

## Step 1: Create Directory Structure

```bash
mkdir -p ~/mediaserver/config
mkdir -p ~/mediaserver/caddy/{data,config}
```

## Step 2: Get Your NordVPN WireGuard Key

Before creating the environment file, you need your NordVPN WireGuard private key.

**See [Appendix A: NordVPN WireGuard Key](../appendices/A-nordvpn-wireguard-key.md) for detailed instructions.**

Quick summary:
1. Log into your NordVPN account
2. Go to Services > NordVPN
3. Generate an access token
4. Use the nordlynx container to convert it to a WireGuard key

## Step 3: Create the Environment File

Create the environment file:

```bash
nano ~/mediaserver/.env
```

Add the following content:

```
# ============================================
# Home Media Server - Environment Configuration
# ============================================
# Keep this file secure - it contains secrets!

# User/Group IDs (run 'id' to find yours)
PUID=1000
PGID=1000
TZ=America/New_York

# NordVPN WireGuard (see Appendix A)
WIREGUARD_PRIVATE_KEY=YOUR_PRIVATE_KEY_HERE

# Paths
DOWNLOADS_PATH=/home/your-username/downloads
MEDIA_PATH=/data/media
CONFIG_PATH=/home/your-username/mediaserver/config
```

Save and exit (Ctrl+X, then Y, then Enter).

**Important:** Edit this file and replace:
- `YOUR_PRIVATE_KEY_HERE` with your actual NordVPN WireGuard private key
- `your-username` with your actual username (in three places)
- `America/New_York` with your timezone (e.g., `America/Los_Angeles`, `Europe/London`)

Find your user/group IDs:
```bash
id
```

Secure the file:
```bash
chmod 600 ~/mediaserver/.env
```

## Step 4: Create the Docker Compose File

Create the Docker Compose file:

```bash
nano ~/mediaserver/docker-compose.yml
```

Add the following content:

```yaml
services:
  # ===================
  # VPN + Download Client
  # ===================
  nordlynx:
    image: ghcr.io/bubuntux/nordlynx
    container_name: nordlynx
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
      - QUERY=filters\[servers_groups\]\[identifier\]=legacy_p2p
      - NET_LOCAL=192.168.0.0/16
      - TZ=${TZ}
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.conf.all.rp_filter=2
      - net.ipv6.conf.all.disable_ipv6=1
    ports:
      - "127.0.0.1:8080:8080"   # qBittorrent WebUI (localhost only)
    restart: unless-stopped

  qbittorrent:
    image: linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "service:nordlynx"
    depends_on:
      - nordlynx
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - WEBUI_PORT=8080
      - TORRENTING_PORT=6881
    volumes:
      - ${CONFIG_PATH}/qbittorrent:/config
      - ${DOWNLOADS_PATH}:/downloads
    restart: unless-stopped

  # ===================
  # *arr Stack
  # ===================
  sonarr:
    image: linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${CONFIG_PATH}/sonarr:/config
      - ${MEDIA_PATH}/tv:/tv
      - ${DOWNLOADS_PATH}:/downloads
    ports:
      - "8989:8989"
    restart: unless-stopped

  radarr:
    image: linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${CONFIG_PATH}/radarr:/config
      - ${MEDIA_PATH}/movies:/movies
      - ${DOWNLOADS_PATH}:/downloads
    ports:
      - "7878:7878"
    restart: unless-stopped

  prowlarr:
    image: linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${CONFIG_PATH}/prowlarr:/config
    ports:
      - "9696:9696"
    restart: unless-stopped

  bazarr:
    image: linuxserver/bazarr:latest
    container_name: bazarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${CONFIG_PATH}/bazarr:/config
      - ${MEDIA_PATH}/movies:/movies
      - ${MEDIA_PATH}/tv:/tv
    ports:
      - "6767:6767"
    restart: unless-stopped

  jellyseerr:
    image: fallenbagel/jellyseerr:latest
    container_name: jellyseerr
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ}
    volumes:
      - ${CONFIG_PATH}/jellyseerr:/app/config
    ports:
      - "5055:5055"
    restart: unless-stopped

  # ===================
  # Infrastructure
  # ===================
  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /home/${USER}/mediaserver/Caddyfile:/etc/caddy/Caddyfile:ro
      - /home/${USER}/mediaserver/caddy/data:/data
      - /home/${USER}/mediaserver/caddy/config:/config

  ddns-updater:
    image: qmcgaw/ddns-updater:latest
    container_name: ddns-updater
    restart: unless-stopped
    environment:
      - TZ=${TZ}
    volumes:
      - ${CONFIG_PATH}/ddns:/updater/data
```

Save and exit (Ctrl+X, then Y, then Enter).

> **Note:** We'll create the Caddyfile and DDNS config later in the Remote Access chapters.

## Step 5: Start the Core Services

Start everything except Caddy and DDNS (we'll configure those later):

```bash
cd ~/mediaserver
docker compose up -d nordlynx qbittorrent sonarr radarr prowlarr bazarr jellyseerr
```

## Step 6: Verify Containers Are Running

```bash
docker compose ps
```

Expected output (all should show "Up"):
```
NAME          IMAGE                              STATUS
nordlynx      ghcr.io/bubuntux/nordlynx         Up
qbittorrent   linuxserver/qbittorrent:latest    Up
sonarr        linuxserver/sonarr:latest         Up
radarr        linuxserver/radarr:latest         Up
prowlarr      linuxserver/prowlarr:latest       Up
bazarr        linuxserver/bazarr:latest         Up
jellyseerr    fallenbagel/jellyseerr:latest     Up
```

## Step 7: Verify VPN is Working

Check that qBittorrent is using the VPN:

```bash
docker exec nordlynx curl -s https://ifconfig.io
```

This should show a NordVPN IP address, **not** your home IP.

Compare with your actual public IP:
```bash
curl -s https://ifconfig.io
```

These two IPs should be different.

## Step 8: Access the Web Interfaces

Open each service in your browser (replace `<server-ip>` with your server's IP):

| Service | URL |
|---------|-----|
| qBittorrent | `http://localhost:8080` (SSH tunnel required - see below) |
| Sonarr | `http://<server-ip>:8989` |
| Radarr | `http://<server-ip>:7878` |
| Prowlarr | `http://<server-ip>:9696` |
| Bazarr | `http://<server-ip>:6767` |
| Jellyseerr | `http://<server-ip>:5055` |

### Accessing qBittorrent

qBittorrent is bound to localhost only for security. To access it, use an SSH tunnel:

```bash
ssh -L 8080:localhost:8080 your-username@<server-ip>
```

Then open `http://localhost:8080` in your browser.

Default credentials:
- Username: `admin`
- Password: Check the logs for the initial password:
  ```bash
  docker logs qbittorrent 2>&1 | grep -i password
  ```

## Container Management Commands

Here are useful commands for managing your containers:

```bash
cd ~/mediaserver

# View all container status
docker compose ps

# View logs for a specific service
docker compose logs -f sonarr

# Restart a service
docker compose restart sonarr

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Update all containers to latest images
docker compose pull
docker compose up -d

# View resource usage
docker stats
```

## Troubleshooting

### Container Won't Start

Check the logs:
```bash
docker compose logs nordlynx
docker compose logs qbittorrent
```

### VPN Not Connecting

1. Verify your WireGuard private key is correct in `.env`
2. Check nordlynx logs:
   ```bash
   docker logs nordlynx
   ```
3. Try restarting nordlynx:
   ```bash
   docker compose restart nordlynx
   ```

### "Permission denied" Errors

Make sure PUID and PGID in `.env` match your user:
```bash
id
```

### Config Files Not Persisting

Check volume mounts are correct:
```bash
docker inspect sonarr | grep -A 10 Mounts
```

### Services Can't Communicate

All services are on the same Docker network. They can reach each other by container name (e.g., `sonarr` can reach `radarr` at `http://radarr:7878`).

## What's Next

The Docker stack is running, but the services need to be configured. In the next chapters, we'll configure each service:

1. [qBittorrent](08-configure-qbittorrent.md) - Download client settings
2. [Prowlarr](09-configure-prowlarr.md) - Indexer management
3. [Sonarr](10-configure-sonarr.md) - TV automation
4. [Radarr](11-configure-radarr.md) - Movie automation
5. [Bazarr](12-configure-bazarr.md) - Subtitles (optional)
6. [Jellyseerr](13-configure-jellyseerr.md) - Requests (optional)

---

**Previous:** [Chapter 6: Install Plex](06-install-plex.md)

**Next:** [Chapter 8: Configure qBittorrent](08-configure-qbittorrent.md)
