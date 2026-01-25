# Chapter 16: Caddy Reverse Proxy (Optional)

> **This chapter is optional.** Caddy provides pretty URLs with HTTPS (`https://media.example.com`) for accessing services externally. If you only need Plex remote access, skip to [Chapter 18: Plex Remote Access](18-plex-remote-access.md) - Plex has built-in remote streaming that works without a domain or reverse proxy.

Caddy is a web server that automatically handles HTTPS certificates. It acts as a reverse proxy, routing requests from your domain to the appropriate internal services.

## Why Use Caddy?

- **Pretty URLs**: Access services via `https://jellyseerr.example.com` instead of `http://192.168.1.50:5055`
- **HTTPS everywhere**: Automatic SSL certificates from Let's Encrypt
- **External access to *arr apps**: Let trusted users access Jellyseerr, or yourself access Sonarr/Radarr remotely
- **Single entry point**: All traffic comes through ports 80/443

## Overview

Caddy will:
- Automatically obtain Let's Encrypt SSL certificates
- Route `your-domain.com` to Jellyseerr
- Route `sonarr.your-domain.com` to Sonarr
- Route `radarr.your-domain.com` to Radarr
- Handle certificate renewals automatically

## Prerequisites

- Domain configured with DNS pointing to your IP ([Chapter 14](14-domain-and-dns.md))
- Router port forwarding configured ([Chapter 15](15-router-configuration.md))
- Ports 80 and 443 forwarded to your server

## Step 1: Create the Caddyfile

The Caddyfile tells Caddy how to route requests.

Create `~/mediaserver/Caddyfile`:

```bash
cat << 'EOF' > ~/mediaserver/Caddyfile
{
    email your-email@example.com
}

# Main domain - Jellyseerr (request interface)
your-domain.com {
    reverse_proxy jellyseerr:5055
}

# Sonarr - TV show management
sonarr.your-domain.com {
    reverse_proxy sonarr:8989
}

# Radarr - Movie management
radarr.your-domain.com {
    reverse_proxy radarr:7878
}
EOF
```

**Important:** Replace in the file:
- `your-email@example.com` with your actual email (for Let's Encrypt notifications)
- `your-domain.com` with your actual domain (in all three places)

Edit the file:
```bash
nano ~/mediaserver/Caddyfile
```

## Step 2: Create Caddy Directories

```bash
mkdir -p ~/mediaserver/caddy/{data,config}
```

## Step 3: Start Caddy

```bash
cd ~/mediaserver
docker compose up -d caddy
```

## Step 4: Verify Certificate Issuance

Check Caddy logs for certificate activity:

```bash
docker logs caddy --tail 100
```

Look for messages like:
```
certificate obtained successfully
```

If you see errors about certificate issuance:
1. Verify DNS points to your public IP
2. Verify ports 80/443 are forwarded
3. Check that the domain resolves correctly

## Step 5: Test HTTPS Access

Open your browser and test each URL:

- `https://your-domain.com` → Jellyseerr
- `https://sonarr.your-domain.com` → Sonarr
- `https://radarr.your-domain.com` → Radarr

All should load with a valid HTTPS certificate (padlock icon).

### Test from Command Line

```bash
curl -I https://your-domain.com
```

Should return `HTTP/2 200` or similar.

## Adding More Services

To expose additional services, edit the Caddyfile:

```bash
nano ~/mediaserver/Caddyfile
```

### Example: Add Prowlarr

```
prowlarr.your-domain.com {
    reverse_proxy prowlarr:9696
}
```

### Example: Add Bazarr

```
bazarr.your-domain.com {
    reverse_proxy bazarr:6767
}
```

After editing, reload Caddy:
```bash
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

Or restart:
```bash
docker compose restart caddy
```

## Security: Adding Basic Authentication

To add password protection to services (useful for Sonarr/Radarr which have their own auth):

```
sonarr.your-domain.com {
    basicauth * {
        admin $2a$14$... # hashed password
    }
    reverse_proxy sonarr:8989
}
```

Generate password hash:
```bash
docker exec caddy caddy hash-password
```

## Advanced: Rate Limiting (Optional)

Add rate limiting to prevent abuse:

```
your-domain.com {
    rate_limit {
        zone jellyseerr {
            key {remote_host}
            events 100
            window 1m
        }
    }
    reverse_proxy jellyseerr:5055
}
```

## Caddyfile Reference

### Full Example Caddyfile

```
{
    email your-email@example.com
}

# Jellyseerr - Request interface (main domain)
your-domain.com {
    reverse_proxy jellyseerr:5055
}

# Sonarr - TV management
sonarr.your-domain.com {
    reverse_proxy sonarr:8989
}

# Radarr - Movie management
radarr.your-domain.com {
    reverse_proxy radarr:7878
}

# Prowlarr - Indexer management (optional)
prowlarr.your-domain.com {
    reverse_proxy prowlarr:9696
}

# Bazarr - Subtitle management (optional)
bazarr.your-domain.com {
    reverse_proxy bazarr:6767
}
```

## Troubleshooting

### Certificate Not Issued

1. **Check DNS resolution**:
   ```bash
   dig +short your-domain.com
   ```
   Should show your public IP.

2. **Check port 80 is accessible** (required for HTTP-01 challenge):
   ```bash
   # From outside your network
   curl -I http://your-domain.com
   ```

3. **Check Caddy logs**:
   ```bash
   docker logs caddy 2>&1 | grep -i "error\|certificate"
   ```

4. **Rate limiting**: Let's Encrypt has rate limits. If you've failed too many times, wait an hour.

### 502 Bad Gateway

Caddy can reach your domain but can't reach the internal service:

1. Check service is running:
   ```bash
   docker ps | grep jellyseerr
   ```

2. Check Caddy can reach service:
   ```bash
   docker exec caddy wget -qO- http://jellyseerr:5055
   ```

3. Verify container name matches Caddyfile

### ERR_CONNECTION_REFUSED

1. Check Caddy is running:
   ```bash
   docker ps | grep caddy
   ```

2. Check ports are published:
   ```bash
   docker port caddy
   ```
   Should show `80/tcp` and `443/tcp`.

3. Verify port forwarding on router

### Certificate Renewal

Caddy automatically renews certificates before they expire. Check certificate status:

```bash
docker exec caddy caddy list-modules
```

Check certificate expiry:
```bash
openssl s_client -connect your-domain.com:443 -servername your-domain.com 2>/dev/null | openssl x509 -noout -dates
```

## Where Certificates Are Stored

Caddy stores certificates in the volume:
- Container path: `/data`
- Host path: `~/mediaserver/caddy/data/`

**Don't delete these files** - you'll hit Let's Encrypt rate limits if you regenerate too often.

## Quick Reference

| URL | Service | Internal Address |
|-----|---------|------------------|
| `your-domain.com` | Jellyseerr | `jellyseerr:5055` |
| `sonarr.your-domain.com` | Sonarr | `sonarr:8989` |
| `radarr.your-domain.com` | Radarr | `radarr:7878` |

## Next Steps

Caddy is running and serving your services over HTTPS. Next, we'll set up DDNS to automatically update DNS records when your IP changes.

---

**Previous:** [Chapter 15: Router Configuration](15-router-configuration.md)

**Next:** [Chapter 17: DDNS Updater](17-ddns-updater.md)
