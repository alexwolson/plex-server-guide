# Chapter 18: Plex Remote Access

Plex has built-in remote access that lets you stream from anywhere. This chapter covers configuring it for optimal performance.

> **Note:** Plex remote access works independently of domains and reverse proxies. You do NOT need a domain name, Caddy, or DDNS for Plex to stream remotely. All you need is port 32400 forwarded on your router.

## Overview

Plex remote access can work two ways:
1. **Direct connection** - Viewers connect directly to your server (best quality)
2. **Relay** - Traffic goes through Plex's servers (fallback, limited quality)

We'll configure direct connections for the best experience.

## Prerequisites

- Plex installed and running ([Chapter 6](06-install-plex.md))
- Port 32400 forwarded on your router ([Chapter 15](15-router-configuration.md))
- (Optional) Domain configured - only if you want `https://plex.example.com` access

## Step 1: Access Plex Settings

1. Open Plex Web: `http://<server-ip>:32400/web`
2. Click the **wrench icon** (Settings)
3. Go to **Remote Access** under Settings

## Step 2: Enable Remote Access

1. Toggle **Remote Access** to enabled
2. Plex will attempt to configure automatically

### If It Shows "Fully accessible outside your network"

Port forwarding is working. You're done with the basic setup.

### If It Shows "Not available outside your network"

Click **Show Advanced** and configure manually:

1. Check **Manually specify public port**
2. Enter **32400** (or whatever port you forwarded)
3. Click **Retry**

## Step 3: Test Remote Access

### Test from Plex

The Remote Access page shows the connection status:
- **Green checkmark** - Direct connections working
- **Orange warning** - Using relay (limited)
- **Red X** - Not accessible

### Test from Outside Your Network

Use your phone on cellular (not WiFi):
1. Open the Plex app
2. Your server should appear
3. Try playing something

Or use [Plex Web](https://app.plex.tv) from outside your network.

## Understanding Direct vs Relay

| Connection | Speed | Quality | Notes |
|------------|-------|---------|-------|
| Direct | Full | Original | Best experience |
| Relay | 2 Mbps max | Transcoded | Fallback only |

Direct connections require port 32400 to be accessible.

## Bandwidth Settings

Configure how Plex handles remote streaming:

1. Go to **Settings** > **Remote Access**
2. Under **Internet upload speed**, set your actual upload speed
3. Under **Limit remote stream bitrate**, set maximum allowed

### Recommendations

| Your Upload Speed | Recommended Limit |
|-------------------|-------------------|
| 10 Mbps | 8 Mbps (1080p) |
| 20 Mbps | 12 Mbps (1080p+) |
| 50+ Mbps | 20 Mbps or Original |

## Secure Connections

Enable secure connections for HTTPS:

1. Go to **Settings** > **Network**
2. **Secure connections**: Set to **Preferred** or **Required**
3. Plex will use HTTPS for all connections

## Custom Domain for Plex (Optional)

You can access Plex through your domain via Caddy, but it's usually not necessary since Plex handles its own connectivity.

If you want `plex.your-domain.com`:

Add to your Caddyfile:
```
plex.your-domain.com {
    reverse_proxy localhost:32400
}
```

Then add DNS record for `plex` subdomain.

## Troubleshooting

### "Not available outside your network"

1. **Verify port forwarding**:
   - Log into router
   - Check port 32400 → server IP

2. **Check firewall on server**:
   ```bash
   sudo ufw status
   ```
   If active:
   ```bash
   sudo ufw allow 32400/tcp
   ```

3. **Test port externally**:
   - Use [canyouseeme.org](https://canyouseeme.org)
   - Test port 32400

4. **Check Plex is listening**:
   ```bash
   sudo netstat -tlnp | grep 32400
   ```

### Double NAT

If your ISP router is separate from your WiFi router:
1. Enable bridge mode on ISP router, or
2. Port forward 32400 on both routers

### CGNAT

If your ISP uses CGNAT:
- Port forwarding won't work
- You'll always use relay
- Contact ISP for a real public IP
- Or use Tailscale/VPN solution

### Relay Only (Can't Get Direct)

If you can't get direct connections:
1. Relay still works but is limited to ~2 Mbps
2. Consider Plex Pass for relay priority
3. Try during off-peak hours

### Buffering Issues

1. Check your upload speed matches settings
2. Lower remote stream quality in Plex settings
3. Enable **Allow Relay** as fallback
4. Check if transcoding is overloading server

## Remote Access for Friends/Family

When sharing your server:

1. Go to **Settings** > **Users & Sharing**
2. Click **Share Library**
3. Enter their Plex username or email
4. Select libraries to share
5. They'll see your server in their Plex apps

### What They Need

- Plex account (free)
- Plex app (free on most platforms)
- Accept your invite

## Mobile Sync (Plex Pass)

With Plex Pass, users can download content for offline viewing:

1. Go to **Settings** > **Library**
2. Enable **Allow Sync**
3. Users can then download to mobile devices

## Quick Reference

| Setting | Location | Value |
|---------|----------|-------|
| Remote Access | Settings > Remote Access | Enabled |
| Port | Settings > Remote Access | 32400 |
| Secure Connections | Settings > Network | Preferred |
| Upload Speed | Settings > Remote Access | Your actual speed |

## Next Steps

Plex remote access is configured. You can now stream from anywhere.

Next are optional chapters:
- [VPN Kill-Switch](19-vpn-killswitch.md) - Extra security for VPN
- [get-iplayer](20-get-iplayer.md) - BBC content
- [Verification Checklist](21-verification-checklist.md) - Confirm everything works

---

**Previous:** [Chapter 17: DDNS Updater](17-ddns-updater.md)

**Next:** [Chapter 19: VPN Kill-Switch (Optional)](19-vpn-killswitch.md)
