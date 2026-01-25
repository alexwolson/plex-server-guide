# Chapter 15: Router Configuration

To access your server from outside your home network, you need to configure your router to forward traffic to your server.

## Overview

We'll configure:
- Static IP or DHCP reservation for your server
- Port forwarding for Plex (required for remote streaming)
- Port forwarding for HTTP/HTTPS (optional, only if using a domain)

## What's Required vs Optional

| Port | Service | Required? |
|------|---------|-----------|
| 32400 | Plex | **Yes** - Required for Plex remote streaming |
| 80 | HTTP (Caddy) | Optional - Only if using a domain |
| 443 | HTTPS (Caddy) | Optional - Only if using a domain |

> **Minimum setup:** If you only want Plex remote access (no domain), you only need to forward port 32400.

## Prerequisites

- Access to your router's admin interface
- Your server's local IP address
- (Optional) Domain and DNS configured ([Chapter 14](14-domain-and-dns.md)) if using Caddy

## Step 1: Find Your Server's Local IP

On your server:
```bash
ip -4 addr show | grep -oP '(?<=inet\s)192\.168\.[0-9.]+' | head -1
```

Or:
```bash
hostname -I | awk '{print $1}'
```

Your local IP will be something like `192.168.1.50` or `192.168.0.100`.

## Step 2: Access Your Router

### Common Router Addresses

Try these URLs in your browser:
- `http://192.168.1.1`
- `http://192.168.0.1`
- `http://10.0.0.1`
- `http://192.168.1.254`

### Find Your Gateway

If none of those work, find your router's IP:
```bash
ip route | grep default
```

Look for `default via X.X.X.X` - that's your router IP.

### Router Credentials

Check:
- Label on your router (default credentials)
- Documentation from your ISP
- Common defaults: admin/admin, admin/password

## Step 3: Set Static IP (Recommended)

Your server should always have the same local IP. Two approaches:

### Option A: DHCP Reservation (Recommended)

Configure your router to always assign the same IP to your server:

1. Find **DHCP Settings** or **LAN Settings**
2. Look for **DHCP Reservations** or **Address Reservation**
3. Add your server:
   - **MAC Address**: Find with `ip link show` (look for `link/ether`)
   - **IP Address**: Your current IP or a new one
4. Save

### Option B: Static IP on Server

Configure a static IP directly on Ubuntu:

1. Find your network interface:
   ```bash
   ip link show
   ```
   Usually `eth0`, `enp0s3`, or similar.

2. Create a netplan config:
   ```bash
   sudo nano /etc/netplan/99-static.yaml
   ```

3. Add:
   ```yaml
   network:
     version: 2
     ethernets:
       eth0:  # Change to your interface name
         addresses:
           - 192.168.1.50/24  # Your chosen static IP
         routes:
           - to: default
             via: 192.168.1.1  # Your router IP
         nameservers:
           addresses:
             - 8.8.8.8
             - 8.8.4.4
   ```

4. Apply:
   ```bash
   sudo netplan apply
   ```

## Step 4: Configure Port Forwarding

### Ports to Forward

| External Port | Internal Port | Protocol | Service | Required? |
|---------------|---------------|----------|---------|-----------|
| 32400 | 32400 | TCP | Plex | **Yes** |
| 80 | 80 | TCP | HTTP (Caddy) | Optional |
| 443 | 443 | TCP | HTTPS (Caddy) | Optional |

> **Plex-only setup:** If you're not using a domain/Caddy, you only need to forward port 32400.

### General Steps (Varies by Router)

1. Find **Port Forwarding** / **NAT** / **Virtual Servers**
2. Create new rules for each port:

#### Rule 1: Plex (Required)

| Setting | Value |
|---------|-------|
| Name/Description | Plex |
| External Port | 32400 |
| Internal IP | Your server's local IP |
| Internal Port | 32400 |
| Protocol | TCP |

#### Rule 2: HTTP (Optional - Only if using domain/Caddy)

| Setting | Value |
|---------|-------|
| Name/Description | HTTP |
| External Port | 80 |
| Internal IP | Your server's local IP |
| Internal Port | 80 |
| Protocol | TCP |

#### Rule 3: HTTPS (Optional - Only if using domain/Caddy)

| Setting | Value |
|---------|-------|
| Name/Description | HTTPS |
| External Port | 443 |
| Internal IP | Your server's local IP |
| Internal Port | 443 |
| Protocol | TCP |

3. Save and apply changes

### Router-Specific Guides

#### ASUS Routers

1. **WAN** > **Virtual Server / Port Forwarding**
2. Enable port forwarding
3. Add entries for each port
4. Apply

#### Netgear Routers

1. **Advanced** > **Setup** > **Port Forwarding**
2. Add Custom Service
3. Enter port details
4. Apply

#### TP-Link Routers

1. **Advanced** > **NAT Forwarding** > **Virtual Servers**
2. Add for each port
3. Save

#### Linksys Routers

1. **Security** > **Apps and Gaming** > **Single Port Forwarding**
2. Add entries
3. Save Settings

#### ISP Router (Generic)

Look for:
- Port Forwarding
- NAT
- Virtual Servers
- Applications & Gaming
- Firewall > Port Forwarding

## Step 5: Verify Port Forwarding

### Test from External Network

Use your phone on cellular (not WiFi) or a site like:
- [yougetsignal.com/tools/open-ports](https://www.yougetsignal.com/tools/open-ports/)
- [canyouseeme.org](https://canyouseeme.org/)

Test ports 80, 443, and 32400.

### Test with curl (After Caddy Setup)

From outside your network:
```bash
curl -I https://your-domain.com
```

Should return HTTP headers if everything is working.

## Troubleshooting

### Ports Show as Closed

1. **Verify Caddy is running** (for ports 80/443):
   ```bash
   docker ps | grep caddy
   ```

2. **Check Plex is listening** (for 32400):
   ```bash
   sudo netstat -tlnp | grep 32400
   ```

3. **Verify firewall isn't blocking**:
   ```bash
   sudo ufw status
   ```
   If active, allow the ports:
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 32400/tcp
   ```

4. **Double-check port forwarding rules**

### Double NAT

If your ISP router is separate from your WiFi router:
- You may have double NAT
- Port forward on ISP router to your router
- Then port forward on your router to server
- Or enable bridge mode on ISP router

### ISP Blocking Ports

Some ISPs block port 80 or 443:
- Contact ISP to unblock
- Use alternate ports (8080, 8443) if allowed
- Consider a VPN tunnel solution

### CGNAT

If you're behind CGNAT (Carrier-Grade NAT):
- Your public IP is shared with others
- Port forwarding won't work
- Solutions: VPN tunnel, Cloudflare Tunnel, Tailscale
- Contact ISP about getting a real public IP

## Security Considerations

### What's Being Exposed

| Port | Risk Level | Notes |
|------|------------|-------|
| 80/443 | Low | Only Caddy exposed, handles routing |
| 32400 | Low | Plex only, requires authentication |

### What's NOT Exposed

- qBittorrent (localhost only)
- Internal service ports (8989, 7878, etc.)

All services except Plex go through Caddy with HTTPS.

## Quick Reference

| Port | Service | Required? |
|------|---------|-----------|
| 32400 | Plex | **Yes** (for Plex remote) |
| 80 | HTTP → Caddy | Optional (only for domain/HTTPS) |
| 443 | HTTPS → Caddy | Optional (only for domain/HTTPS) |

## Next Steps

Ports are forwarded.

- **If using a domain:** Continue to [Chapter 16: Caddy Reverse Proxy](16-caddy-reverse-proxy.md)
- **If NOT using a domain:** Skip to [Chapter 18: Plex Remote Access](18-plex-remote-access.md)

---

**Previous:** [Chapter 14: Domain and DNS](14-domain-and-dns.md)

**Next:** [Chapter 16: Caddy Reverse Proxy](16-caddy-reverse-proxy.md)
