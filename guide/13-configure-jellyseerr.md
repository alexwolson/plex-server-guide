# Chapter 13: Configure Jellyseerr (Optional)

[Jellyseerr](https://github.com/seerr-team/seerr) provides a user-friendly interface for requesting movies and TV shows. Share it with friends and family so they can request content without accessing Sonarr/Radarr directly.

> **This chapter is optional.** If you don't need request management, skip to [Chapter 14](14-domain-and-dns.md).

> **Note: Jellyseerr is merging with Overseerr.** Jellyseerr was originally a fork of Overseerr (which only supported Plex). The two projects are currently merging into a unified app called **Seerr**. As of this writing, Seerr is in beta. Once Seerr reaches stable release, parts of this chapter will need updating—the Docker image name, some configuration steps, and possibly the port may change. For now, Jellyseerr continues to work and receive updates. Check the [Seerr GitHub](https://github.com/seerr-team/seerr) for the latest status.

## Overview

Jellyseerr:
- Provides a beautiful request interface
- Integrates with Plex for user authentication
- Sends requests to Sonarr and Radarr
- Tracks request status and notifies users
- Manages user permissions and quotas

## Prerequisites

- Docker Compose stack running ([Chapter 7](07-docker-compose-stack.md))
- Sonarr configured ([Chapter 10](10-configure-sonarr.md))
- Radarr configured ([Chapter 11](11-configure-radarr.md))
- Plex installed and configured ([Chapter 6](06-install-plex.md))

## Access Jellyseerr

Open your browser:
```
http://<server-ip>:5055
```

## Initial Setup Wizard

### Step 1: Sign In with Plex

1. Click **Sign In with Plex**
2. Log into your Plex account
3. Authorize Jellyseerr

You'll be redirected back to Jellyseerr as an administrator.

### Step 2: Configure Plex Server

1. Jellyseerr should detect your Plex server
2. If not, click **Add Server Manually**:
   - **Hostname**: `<server-ip>`
   - **Port**: `32400`
3. Select your server from the list
4. Enable **Sync Libraries**
5. Select which libraries to sync:
   - Movies
   - TV Shows
6. Click **Continue**

### Step 3: Configure Radarr

1. Click **Add Radarr Server**
2. Configure:

| Setting | Value |
|---------|-------|
| Default Server | Yes |
| Server Name | Radarr |
| Hostname | `radarr` |
| Port | `7878` |
| API Key | (copy from Radarr Settings > General) |
| Quality Profile | HD-1080p (or your preference) |
| Root Folder | `/movies` |
| Minimum Availability | Released |

3. Click **Test** - should show green checkmark
4. Click **Add Server**
5. Click **Continue**

### Step 4: Configure Sonarr

1. Click **Add Sonarr Server**
2. Configure:

| Setting | Value |
|---------|-------|
| Default Server | Yes |
| Server Name | Sonarr |
| Hostname | `sonarr` |
| Port | `8989` |
| API Key | (copy from Sonarr Settings > General) |
| Quality Profile | HD-1080p (or your preference) |
| Root Folder | `/tv` |
| Language Profile | (if shown) English |

3. Click **Test** - should show green checkmark
4. Click **Add Server**
5. Click **Finish Setup**

## Configure User Settings

### Import Plex Users

1. Go to **Settings** > **Users**
2. Click **Import Plex Users**
3. Select which users to import
4. Click **Import**

### Default Permissions

Set what new users can do by default:

1. Go to **Settings** > **Users**
2. Under **Global User Permissions**, configure permissions based on your preferences (see [User Permissions Explained](#user-permissions-explained) below)
3. Click **Save Changes**

### Request Limits (Optional)

To prevent users from requesting too much:

1. Edit a user or modify defaults
2. Set **Movie Request Limit**: e.g., 5 per week
3. Set **TV Request Limit**: e.g., 3 per week

## Test a Request

1. Click **Search** in the top bar
2. Search for a movie you don't have
3. Click on it
4. Click **Request**
5. Confirm the request

Check Radarr - the movie should appear with "Monitored" status.

## Customize Appearance

### General Settings

1. Go to **Settings** > **General**
2. Configure:
   - **Application Title**: Your server name
   - **Application URL**: Will be your domain later (e.g., `https://requests.example.com`)

### Notifications (Optional)

Set up notifications for request approvals:

1. Go to **Settings** > **Notifications**
2. Options include:
   - Email
   - Discord webhook
   - Slack
   - Telegram
   - And more

## User Permissions Explained

| Permission | What It Does |
|------------|--------------|
| Request | User can submit requests for movies and TV shows. Without this, they can only browse. |
| Auto-Approve | Requests are immediately sent to Sonarr/Radarr without manual approval. If disabled, an admin must approve each request. |
| Auto-Request Movies | Automatically requests movies from the user's Plex watchlist. Use with caution—can generate many requests. |
| Auto-Request TV | Same as above, but for TV shows. |
| View Requests | User can see other users' requests (not just their own). |
| Manage Requests | User can approve or deny requests made by others. |
| Manage Users | User can edit other users' permissions and settings. |
| Admin | Full access to all settings and features. |

How you configure these depends on your situation. If you trust your users not to request excessive amounts, Auto-Approve saves you from manually approving everything. If you want more control, leave it off and approve requests yourself. Request limits (below) can also help manage this.

## Sharing with Others

After configuring remote access ([Chapter 16](16-caddy-reverse-proxy.md)), users can access Jellyseerr at your domain.

1. Share the URL: `https://your-domain.com` (or subdomain)
2. Users sign in with their Plex account
3. They can browse and request content

## Troubleshooting

### Can't Connect to Plex

1. Verify Plex is running:
   ```bash
   systemctl is-active plexmediaserver
   ```
2. Check Plex is accessible from Docker network:
   ```bash
   docker exec jellyseerr curl -s http://host.docker.internal:32400
   ```
3. Try using your server's actual IP instead of hostname

### Radarr/Sonarr Connection Failed

1. Use container names (`radarr`, `sonarr`) not `localhost`
2. Verify API keys are correct
3. Check services are running:
   ```bash
   docker ps | grep -E "(radarr|sonarr)"
   ```

### Requests Not Appearing in Sonarr/Radarr

1. Check Jellyseerr logs:
   ```bash
   docker logs jellyseerr --tail 100
   ```
2. Verify quality profiles and root folders exist
3. Make sure the request was approved (if auto-approve is off)

### Users Can't Sign In

1. Verify Plex authentication is working
2. Check users exist in Plex
3. Import users again if needed

## Quick Reference

| Setting | Value |
|---------|-------|
| Jellyseerr URL | `http://<server-ip>:5055` |
| Radarr Host (internal) | `radarr` |
| Sonarr Host (internal) | `sonarr` |
| Plex Host | `<server-ip>` or IP address |

## Next Steps

Jellyseerr is configured. Users can now request content through a friendly interface.

Next, we'll set up remote access so you can access everything from outside your home network.

---

**Previous:** [Chapter 12: Configure Bazarr (Optional)](12-configure-bazarr.md)

**Next:** [Chapter 14: Domain and DNS](14-domain-and-dns.md)
