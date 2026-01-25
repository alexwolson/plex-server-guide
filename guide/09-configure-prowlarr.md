# Chapter 9: Configure Prowlarr

Prowlarr is an indexer manager that centralizes your indexer configuration. Instead of adding indexers to each *arr app separately, you configure them once in Prowlarr and sync to all apps.

## Overview

In this chapter, we'll:
- Set up authentication for Prowlarr
- Add qBittorrent as a download client
- Connect Prowlarr to Sonarr and Radarr
- Add indexers (covered in detail in [Appendix B](../appendices/B-indexer-tracker-guide.md))

## Prerequisites

- Docker Compose stack running ([Chapter 7](07-docker-compose-stack.md))
- qBittorrent configured ([Chapter 8](08-configure-qbittorrent.md))

## Access Prowlarr

Open your browser and go to:
```
http://<server-ip>:9696
```

## Initial Setup

### Set Up Authentication

On first access, Prowlarr will prompt you to set up authentication.

1. Select **Forms (Login Page)** for Authentication Method
2. Choose a username and strong password
3. Click **Save**

You'll be redirected to a login page. Log in with your new credentials.

## Add Download Client

Prowlarr needs to know about qBittorrent to send downloads.

1. Go to **Settings** > **Download Clients**
2. Click the **+** button
3. Select **qBittorrent**
4. Configure:

| Setting | Value |
|---------|-------|
| Name | `qBittorrent` |
| Host | `nordlynx` |
| Port | `8080` |
| Username | `admin` |
| Password | (your qBittorrent password) |

5. Click **Test** - should show a green checkmark
6. Click **Save**

> **Note:** We use `nordlynx` as the host because qBittorrent shares the nordlynx container's network.

## Connect to Sonarr

1. Go to **Settings** > **Apps**
2. Click the **+** button
3. Select **Sonarr**
4. Configure:

| Setting | Value |
|---------|-------|
| Name | `Sonarr` |
| Sync Level | Full Sync |
| Prowlarr Server | `http://prowlarr:9696` |
| Sonarr Server | `http://sonarr:8989` |
| API Key | (get from Sonarr - see below) |

### Get Sonarr API Key

1. Open Sonarr: `http://<server-ip>:8989`
2. Go to **Settings** > **General**
3. Copy the **API Key**
4. Paste it into Prowlarr

5. Click **Test** - should show green checkmark
6. Click **Save**

## Connect to Radarr

1. Go to **Settings** > **Apps**
2. Click the **+** button
3. Select **Radarr**
4. Configure:

| Setting | Value |
|---------|-------|
| Name | `Radarr` |
| Sync Level | Full Sync |
| Prowlarr Server | `http://prowlarr:9696` |
| Radarr Server | `http://radarr:7878` |
| API Key | (get from Radarr - see below) |

### Get Radarr API Key

1. Open Radarr: `http://<server-ip>:7878`
2. Go to **Settings** > **General**
3. Copy the **API Key**
4. Paste it into Prowlarr

5. Click **Test** - should show green checkmark
6. Click **Save**

## Add Indexers

Indexers are search engines for content. There are two types:

- **Public Indexers** - Open to everyone, no account needed
- **Private Trackers** - Require membership/invitation

### Adding a Public Indexer Example

1. Go to **Indexers**
2. Click the **+** button
3. Browse the list or search for an indexer
4. Select an indexer and configure it
5. Click **Test**
6. Click **Save**

> **See [Appendix B: Indexer Guide](../appendices/B-indexer-tracker-guide.md) for detailed information about indexers.**

### Sync Indexers to Apps

After adding indexers:

1. Go to **Settings** > **Apps**
2. Click on **Sonarr**
3. Click **Sync App Indexers**

Repeat for Radarr.

Alternatively, indexers sync automatically on a schedule.

## Understanding Tags (Optional)

Tags let you control which indexers sync to which apps.

Example: If you have a TV-only indexer:
1. Create a tag called `tv-only` in Prowlarr (**Settings** > **Tags**)
2. Add this tag to the indexer
3. Add the same tag to Sonarr (but not Radarr)
4. Only Sonarr will receive this indexer

For most setups, you can skip tags and let all indexers sync to all apps.

## Test the Setup

### Verify Apps Are Connected

Go to **Settings** > **Apps**. Both Sonarr and Radarr should show green checkmarks.

### Test Search

1. Go to **Search** in the left menu
2. Enter a movie or TV show name
3. Click **Search**
4. Results should appear from your indexers

If results appear, Prowlarr is working correctly.

## Troubleshooting

### "Connection Refused" When Adding App

Make sure you're using container names (not localhost):
- Sonarr: `http://sonarr:8989`
- Radarr: `http://radarr:7878`

### API Key Test Fails

1. Verify the API key is correct (no extra spaces)
2. Check the app is running:
   ```bash
   docker ps | grep sonarr
   ```
3. Check Prowlarr can reach the app:
   ```bash
   docker exec prowlarr curl -s http://sonarr:8989
   ```

### Indexers Not Syncing

1. Go to **Settings** > **Apps**
2. Click on the app
3. Click **Sync App Indexers**
4. Check **System** > **Tasks** for sync status

### No Search Results

1. Verify indexers are configured correctly
2. Check indexer status in **Indexers** list
3. Test individual indexers with the **Test** button
4. Some indexers may be temporarily down

## Quick Reference

| Setting | Value |
|---------|-------|
| Prowlarr URL | `http://<server-ip>:9696` |
| qBittorrent Host | `nordlynx` |
| qBittorrent Port | `8080` |
| Sonarr URL (internal) | `http://sonarr:8989` |
| Radarr URL (internal) | `http://radarr:7878` |

## Next Steps

Prowlarr is configured and connected to your *arr apps. Next, we'll configure Sonarr for TV show automation.

---

**Previous:** [Chapter 8: Configure qBittorrent](08-configure-qbittorrent.md)

**Next:** [Chapter 10: Configure Sonarr](10-configure-sonarr.md)
