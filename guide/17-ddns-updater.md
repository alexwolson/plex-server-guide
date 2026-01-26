# Chapter 17: DDNS Updater (Optional)

> **This chapter is optional.** DDNS is only needed if you're using a domain name ([Chapter 14](14-domain-and-dns.md)) AND have a dynamic home IP address. If you're not using a domain, skip to [Chapter 18: Plex Remote Access](18-plex-remote-access.md).

Most home internet connections have dynamic IP addresses that change periodically. DDNS (Dynamic DNS) automatically updates your DNS records when your IP changes, keeping your domain pointed at your server.

## Overview

[ddns-updater](https://github.com/qdm12/ddns-updater) will:
- Monitor your public IP address
- Update Porkbun DNS records when it changes
- Run continuously in the background
- Log all IP changes

## Prerequisites

- Domain purchased from Porkbun ([Chapter 14](14-domain-and-dns.md))
- Porkbun API credentials (API Key and Secret)
- Docker Compose stack running

## Step 1: Create Config Directory

```bash
mkdir -p ~/mediaserver/config/ddns
```

## Step 2: Create Configuration File

Create the configuration file:

```bash
nano ~/mediaserver/config/ddns/config.json
```

Add the following content:

```json
{
  "settings": [
    {
      "provider": "porkbun",
      "domain": "your-domain.com",
      "host": "@",
      "api_key": "pk1_your_api_key",
      "secret_api_key": "sk1_your_secret_key",
      "ip_version": "ipv4",
      "ipv6_suffix": ""
    },
    {
      "provider": "porkbun",
      "domain": "your-domain.com",
      "host": "sonarr",
      "api_key": "pk1_your_api_key",
      "secret_api_key": "sk1_your_secret_key",
      "ip_version": "ipv4",
      "ipv6_suffix": ""
    },
    {
      "provider": "porkbun",
      "domain": "your-domain.com",
      "host": "radarr",
      "api_key": "pk1_your_api_key",
      "secret_api_key": "sk1_your_secret_key",
      "ip_version": "ipv4",
      "ipv6_suffix": ""
    }
  ]
}
```

Save and exit (Ctrl+X, then Y, then Enter).

**Important:** Replace:
- `your-domain.com` with your actual domain
- `pk1_your_api_key` with your Porkbun API key
- `sk1_your_secret_key` with your Porkbun API secret

### Config Explanation

| Field | Purpose |
|-------|---------|
| `provider` | DNS provider (porkbun) |
| `domain` | Your domain name |
| `host` | Subdomain (`@` for apex, `sonarr` for subdomain) |
| `api_key` | Porkbun API key |
| `secret_api_key` | Porkbun API secret |
| `ip_version` | Use IPv4 |

## Step 3: Start DDNS Updater

```bash
cd ~/mediaserver
docker compose up -d ddns-updater
```

## Step 4: Verify It's Working

### Check Container Status

```bash
docker ps | grep ddns
```

Should show `Up` status.

### Check Logs

```bash
docker logs ddns-updater
```

Look for messages like:
```
INFO[0000] record up to date              domain=your-domain.com host=@ ip=XX.XX.XX.XX
```

### Check Web Interface (Optional)

ddns-updater has a web interface:
```bash
docker logs ddns-updater 2>&1 | grep "listening"
```

It runs on port 8000 internally, but we haven't exposed it. You can add port mapping if you want to monitor it via web.

## Configuration for Other Registrars

If you're not using Porkbun, here are configs for other providers:

### Cloudflare

```json
{
  "provider": "cloudflare",
  "domain": "your-domain.com",
  "host": "@",
  "zone_identifier": "your-zone-id",
  "token": "your-api-token",
  "ip_version": "ipv4"
}
```

### Namecheap

```json
{
  "provider": "namecheap",
  "domain": "your-domain.com",
  "host": "@",
  "password": "your-ddns-password",
  "ip_version": "ipv4"
}
```

### Google Domains (Squarespace)

```json
{
  "provider": "google",
  "domain": "your-domain.com",
  "host": "@",
  "username": "generated-username",
  "password": "generated-password",
  "ip_version": "ipv4"
}
```

See [ddns-updater documentation](https://github.com/qdm12/ddns-updater) for all supported providers.

## Step 5: Test IP Update

To verify updates work, you can force an update:

```bash
docker restart ddns-updater
```

Check logs:
```bash
docker logs ddns-updater --tail 20
```

## Adding More Subdomains

If you add new services with subdomains, add them to the config:

```bash
nano ~/mediaserver/config/ddns/config.json
```

Add a new entry in the `settings` array:
```json
{
  "provider": "porkbun",
  "domain": "your-domain.com",
  "host": "newservice",
  "api_key": "pk1_your_api_key",
  "secret_api_key": "sk1_your_secret_key",
  "ip_version": "ipv4",
  "ipv6_suffix": ""
}
```

Restart to apply:
```bash
docker restart ddns-updater
```

## Troubleshooting

### Authentication Failed

1. Verify API credentials are correct
2. Check API access is enabled for the domain in Porkbun
3. No extra spaces in the config file

### IP Not Updating

1. Check container logs for errors:
   ```bash
   docker logs ddns-updater
   ```

2. Verify internet connectivity:
   ```bash
   docker exec ddns-updater wget -qO- https://ifconfig.io
   ```

3. Check config file syntax (valid JSON):
   ```bash
   cat ~/mediaserver/config/ddns/config.json | python3 -m json.tool
   ```

### Container Won't Start

1. Check config file exists:
   ```bash
   ls -la ~/mediaserver/config/ddns/
   ```

2. Check file permissions:
   ```bash
   chmod 644 ~/mediaserver/config/ddns/config.json
   ```

## How Often Does It Update?

By default, ddns-updater:
- Checks your IP every 5 minutes
- Only updates DNS if IP has changed
- Logs every check and update

## Quick Reference

| File | Purpose |
|------|---------|
| `~/mediaserver/config/ddns/config.json` | DDNS configuration |
| API Key format | `pk1_...` |
| API Secret format | `sk1_...` |

## Next Steps

DDNS is configured and will keep your domain pointing to your server. Next, we'll configure Plex remote access.

---

**Previous:** [Chapter 16: Caddy Reverse Proxy](16-caddy-reverse-proxy.md)

**Next:** [Chapter 18: Plex Remote Access](18-plex-remote-access.md)
