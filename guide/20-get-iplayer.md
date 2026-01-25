# Chapter 20: get-iplayer (Optional)

get-iplayer is a tool for downloading content from BBC iPlayer. This requires a VPN connection to a UK server.

> **This chapter is optional.** Only relevant if you want to download BBC iPlayer content.

## Overview

get-iplayer:
- Downloads programmes from BBC iPlayer
- Requires UK IP address (via VPN)
- Can download TV shows and radio programmes
- Outputs to standard video formats

## Prerequisites

- Docker installed
- NordVPN subscription (or another VPN with UK servers)
- Storage space for downloads

## Legal Notice

BBC iPlayer content is:
- Licensed for UK residents
- Subject to BBC Terms of Use
- May require a valid TV licence

Ensure you comply with applicable laws and terms of service.

## Option 1: Use Existing NordVPN

If your nordlynx container can connect to UK servers, you can run get-iplayer through it.

### Configure NordVPN for UK

Modify your nordlynx configuration to use UK servers:

In your `.env` file or docker-compose.yml, change the QUERY:
```yaml
environment:
  - QUERY=filters\[country_id\]=227
```

Country ID 227 is the UK.

> **Warning:** This changes your VPN for all downloads, not just BBC content. You may want a separate container.

## Option 2: Dedicated get-iplayer Container

A separate container specifically for BBC content.

### Create docker-compose override

Create or edit `~/mediaserver/docker-compose.override.yml`:

```yaml
services:
  get-iplayer:
    image: ghcr.io/ghcr.io/barrycarey/get-iplayer-docker
    container_name: get-iplayer
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
    volumes:
      - ~/mediaserver/config/get-iplayer:/config
      - /data/media/tv:/downloads
    network_mode: "service:nordlynx-uk"
    depends_on:
      - nordlynx-uk

  nordlynx-uk:
    image: ghcr.io/bubuntux/nordlynx
    container_name: nordlynx-uk
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
      - QUERY=filters\[country_id\]=227
      - TZ=Europe/London
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.conf.all.rp_filter=2
      - net.ipv6.conf.all.disable_ipv6=1
    restart: unless-stopped
```

### Start the containers

```bash
cd ~/mediaserver
docker compose -f docker-compose.yml -f docker-compose.override.yml up -d nordlynx-uk get-iplayer
```

## Option 3: Manual Installation

For a simpler approach without Docker:

### Install get-iplayer

```bash
sudo apt-get update
sudo apt-get install -y get-iplayer
```

### Configure

```bash
get-iplayer --prefs-add --output "/data/media/tv"
```

### Usage

You'd need to connect to a UK VPN manually before downloading.

## Using get-iplayer

### Search for Programmes

```bash
docker exec get-iplayer get-iplayer "programme name"
```

Or without Docker:
```bash
get-iplayer "programme name"
```

### Download by PID

```bash
docker exec get-iplayer get-iplayer --pid=<pid>
```

### List Available Programmes

```bash
docker exec get-iplayer get-iplayer --refresh
docker exec get-iplayer get-iplayer --list=tv
```

### Download a Series

```bash
docker exec get-iplayer get-iplayer --get "Series Name"
```

## Verify UK Connection

Check you're connected via UK:

```bash
docker exec nordlynx-uk curl -s https://ifconfig.io/country
```

Should return: `United Kingdom` or `GB`

## Quality Options

| Quality | Flag | Notes |
|---------|------|-------|
| Best | `--quality=best` | Highest available |
| HD | `--quality=hd` | 720p/1080p |
| SD | `--quality=sd` | Standard definition |

Example:
```bash
docker exec get-iplayer get-iplayer --pid=<pid> --quality=hd
```

## Output Format

By default, get-iplayer downloads to MP4. Configure output:

```bash
docker exec get-iplayer get-iplayer --prefs-add --output "/downloads" --file-prefix="<nameshort>-<episodeshort>"
```

## Automation (Advanced)

### PVR Mode

get-iplayer can monitor and automatically download new episodes:

1. Add a search to PVR:
   ```bash
   docker exec get-iplayer get-iplayer --pvr-add="My Series" "Series Name"
   ```

2. Run PVR periodically:
   ```bash
   docker exec get-iplayer get-iplayer --pvr
   ```

3. Set up a cron job for automatic downloads.

## Troubleshooting

### "BBC iPlayer is not available in your area"

VPN isn't connecting to UK:
1. Verify VPN is connected
2. Check country:
   ```bash
   docker exec nordlynx-uk curl -s https://ifconfig.io/country
   ```
3. Try restarting the VPN container

### Downloads Failing

1. Check internet connectivity through VPN
2. Verify get-iplayer is up to date
3. BBC may have changed their format - check for updates

### Authentication Issues

Some content requires BBC account sign-in:
```bash
docker exec get-iplayer get-iplayer --prefs-add --email="your@email.com" --password="password"
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `get-iplayer "search"` | Search for programmes |
| `get-iplayer --pid=XXX` | Download specific programme |
| `get-iplayer --refresh` | Update programme cache |
| `get-iplayer --pvr` | Run automated downloads |

## Next Steps

get-iplayer is configured for BBC iPlayer content. Next, verify your complete setup with the verification checklist.

---

**Previous:** [Chapter 19: VPN Kill-Switch (Optional)](19-vpn-killswitch.md)

**Next:** [Chapter 21: Verification Checklist](21-verification-checklist.md)
