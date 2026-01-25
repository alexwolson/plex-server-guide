# Chapter 14: Domain and DNS (Optional)

> **This chapter is optional.** Plex has built-in remote access that works without a domain name. You can stream from anywhere using just Plex's native connectivity. This chapter is for users who want:
> - Pretty URLs like `https://media.example.com` instead of IP addresses
> - HTTPS access to other services (Jellyseerr, Sonarr, Radarr) from outside your network
> - A more professional-looking setup

**If you skip this chapter:** Jump to [Chapter 18: Plex Remote Access](18-plex-remote-access.md) to set up Plex's built-in remote streaming.

---

## Overview

We'll:
- Purchase a domain name (we recommend Porkbun)
- Create DNS records pointing to your IP
- Get API credentials for automatic DNS updates

## Why You Might Want a Domain

- **HTTPS certificates** require a domain (Let's Encrypt doesn't issue certs for IP addresses)
- **Professional access** - `https://media.example.com` vs `http://123.45.67.89:8989`
- **Dynamic DNS** - Domain keeps working even if your home IP changes
- **External access to *arr apps** - Let trusted users access Jellyseerr, or yourself access Sonarr/Radarr remotely

## Prerequisites

- Credit/debit card for domain purchase
- Knowledge of your public IP (we'll find it below)

## Step 1: Find Your Public IP

Run this from your server:
```bash
curl -s https://ifconfig.io
```

Save this IP - you'll use it when creating DNS records.

> **Note:** If you have a dynamic IP (most residential connections do), this IP may change. We'll set up automatic updates in [Chapter 17](17-ddns-updater.md).

## Step 2: Choose a Domain Name

### Domain Name Tips

- **Keep it short** - easier to type
- **Make it memorable** - you'll share it with users
- **Consider purpose** - media, requests, home, etc.

### Popular TLDs for Media Servers

| TLD | Price | Notes |
|-----|-------|-------|
| `.stream` | ~$25/year | Perfect for media servers |
| `.media` | ~$30/year | Self-explanatory |
| `.tv` | ~$30/year | Great for TV-focused |
| `.com` | ~$10/year | Classic, may be taken |
| `.io` | ~$30/year | Tech-friendly |

### Example Names

- `mymediaserver.stream`
- `familyflix.media`
- `hometheater.tv`
- `smithfamily.stream`

## Step 3: Purchase Domain (Porkbun)

We recommend Porkbun for:
- Competitive pricing
- Free WHOIS privacy
- Good API for DDNS
- Clean interface

### Create Account

1. Go to [porkbun.com](https://porkbun.com)
2. Create an account
3. Verify your email

### Search and Purchase

1. Search for your chosen domain
2. Add to cart
3. Check out
4. Enable **Auto-Renew** to avoid losing the domain

### Alternative Registrars

If you prefer another registrar:
- **Cloudflare** - At-cost pricing, good DNS
- **Namecheap** - Budget-friendly
- **Google Domains** (now Squarespace)

The DDNS configuration will vary by provider.

## Step 4: Create DNS Records

After purchase, configure DNS records to point to your server.

### Access DNS Management

1. Log into Porkbun
2. Go to **Domain Management**
3. Click on your domain
4. Click **DNS**

### Create A Records

You'll create several A records pointing to your public IP:

| Type | Host | Answer | TTL |
|------|------|--------|-----|
| A | (blank for apex) | Your public IP | 600 |
| A | www | Your public IP | 600 |
| A | sonarr | Your public IP | 600 |
| A | radarr | Your public IP | 600 |

> **Tip:** Use a low TTL (600 = 10 minutes) so changes propagate quickly when your IP changes.

### How to Add Each Record

1. Click **Add Record**
2. Select **A - Address Record**
3. **Host**: Enter subdomain (or leave blank for apex)
4. **Answer**: Your public IP
5. **TTL**: 600
6. Click **Save**

### What Each Record Does

| Record | URL | Purpose |
|--------|-----|---------|
| (apex) | `example.com` | Main domain - Jellyseerr |
| www | `www.example.com` | Redirect to apex |
| sonarr | `sonarr.example.com` | Sonarr access |
| radarr | `radarr.example.com` | Radarr access |

## Step 5: Get API Credentials

For automatic DNS updates when your IP changes (DDNS), you need API credentials.

### Porkbun API Setup

1. Go to [porkbun.com/account/api](https://porkbun.com/account/api)
2. Click **Create API Key**
3. Save both values securely:
   - **API Key**: `pk1_...`
   - **API Secret**: `sk1_...`

### Enable API Access for Domain

1. Go to **Domain Management**
2. Click on your domain
3. Find **API Access** and ensure it's **Enabled**

## Step 6: Verify DNS Propagation

DNS changes can take time to propagate (usually minutes, sometimes hours).

### Check from Command Line

```bash
# Check apex record
dig +short example.com

# Check subdomain
dig +short sonarr.example.com
```

Replace `example.com` with your domain.

### Online Tools

- [dnschecker.org](https://dnschecker.org) - Check propagation worldwide
- [whatsmydns.net](https://whatsmydns.net) - Similar service

## DNS Record Reference

Here's a complete list of records you might want:

| Subdomain | Service | Required? |
|-----------|---------|-----------|
| (apex) | Jellyseerr | Recommended |
| sonarr | Sonarr | If exposing externally |
| radarr | Radarr | If exposing externally |
| plex | Plex (via Caddy) | Optional |
| ssh | SSH (if different port) | Optional |

## Troubleshooting

### DNS Not Resolving

1. Wait - propagation can take up to 48 hours (usually much faster)
2. Check records are correct in registrar
3. Try flushing DNS cache:
   - macOS: `sudo dscacheutil -flushcache`
   - Windows: `ipconfig /flushdns`
   - Linux: `sudo systemd-resolve --flush-caches`

### Wrong IP Showing

1. Check the A record has your correct IP
2. Lower TTL if you recently changed it
3. Wait for TTL to expire and recheck

### API Credentials Not Working

1. Verify API Access is enabled for the domain
2. Check credentials are copied correctly (no extra spaces)
3. Some registrars require API access to be enabled per-domain

## Cost Summary

| Item | Typical Cost |
|------|--------------|
| Domain (first year) | $10-30 |
| Domain (renewal) | $10-40 |
| WHOIS Privacy | Free (Porkbun) |
| SSL Certificates | Free (Let's Encrypt) |

## Next Steps

Your domain is purchased and DNS is configured. Next, we'll configure your router to forward traffic to your server.

---

**Previous:** [Chapter 13: Configure Jellyseerr (Optional)](13-configure-jellyseerr.md)

**Next:** [Chapter 15: Router Configuration](15-router-configuration.md)
