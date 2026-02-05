# Chapter 10: Configure Sonarr

[Sonarr](https://github.com/Sonarr/Sonarr) automates TV show downloads. Once configured, it monitors for new episodes of shows you're tracking and automatically downloads them.

## Overview

In this chapter, we'll:
- Set up authentication
- Configure media management settings
- Add root folders
- Connect to qBittorrent
- Verify indexers from Prowlarr
- Add your first TV show

## Prerequisites

- Docker Compose stack running ([Chapter 7](07-docker-compose-stack.md))
- qBittorrent configured ([Chapter 8](08-configure-qbittorrent.md))
- Prowlarr configured with Sonarr connection ([Chapter 9](09-configure-prowlarr.md))

## Access Sonarr

Open your browser:
```
http://<server-ip>:8989
```

## Initial Setup

### Set Up Authentication

1. Go to **Settings** > **General**
2. Under **Security**, set:
   - **Authentication**: Forms (Login Page)
   - **Username**: Your chosen username
   - **Password**: A strong password
3. Click **Save Changes**

You'll be prompted to log in with your new credentials.

## Configure Media Management

### Set Up File Naming

1. Go to **Settings** > **Media Management**
2. Enable **Rename Episodes**
3. Configure naming formats (or use defaults):

**Standard Episode Format:**
```
{Series TitleYear} - S{season:00}E{episode:00} - {Episode CleanTitle} [{Quality Full}]{[MediaInfo VideoDynamicRangeType]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{MediaInfo AudioLanguages}{-Release Group}
```

**Season Folder Format:**
```
Season {season:00}
```



4. Click **Save Changes**

### Enable Advanced Settings

Click **Show Advanced** at the top to see all options.

### More Naming Formats

Now visible with Advanced Settings, set **Series Folder Format:**

```
{Series TitleYear} {imdb-{ImdbId}}
```

### Configure Root Folder Handling

1. Under **Folders**, set:
   - **Delete empty folders**: Enabled (optional)
2. Under **File Management**, set:
   - **Unmonitor Deleted Episodes**: Enabled

## Add Root Folder

The root folder is where Sonarr stores TV shows.

1. Go to **Settings** > **Media Management**
2. Click **Add Root Folder**
3. Navigate to `/tv` and select it
4. Click **OK**

> **Note:** The path `/tv` inside the container maps to `/data/media/tv` on your host.

## Connect Download Client

qBittorrent should already be available via Prowlarr's sync, but let's verify:

1. Go to **Settings** > **Download Clients**
2. You should see **qBittorrent** listed
3. If not, click **+** and add it:

| Setting | Value |
|---------|-------|
| Name | `qBittorrent` |
| Host | `nordlynx` |
| Port | `8080` |
| Username | `admin` |
| Password | (your qBittorrent password) |
| Category | `sonarr` |

4. Click **Test** then **Save**

## Verify Indexers

Check that Prowlarr has synced indexers:

1. Go to **Settings** > **Indexers**
2. You should see indexers that Prowlarr synced
3. If empty, go back to Prowlarr and click **Sync App Indexers**

## Configure Quality Profiles

Quality profiles determine what video quality Sonarr downloads. Go to **Settings** > **Profiles** to view and edit them.

### Understanding Quality Levels

The quality you choose is a trade-off between file size and visual quality. Here's what the different levels mean:

| Quality | Size per Episode | What It Is |
|---------|-----------------|------------|
| HDTV-720p | 500MB–1GB | Recorded from TV broadcast. Decent quality, smallest files. |
| WEBDL-720p/1080p | 1–3GB | Ripped from streaming services (Netflix, etc). Clean, no encoding artifacts. |
| WEBRip-720p/1080p | 1–3GB | Screen-captured from streaming. Slightly lower quality than WEBDL. |
| Bluray-720p/1080p | 2–6GB | Re-encoded from Blu-ray disc. High quality but larger than web sources. |
| Remux-1080p | 15–30GB | Full Blu-ray quality, no re-encoding. Very large files. |
| WEBDL-2160p | 5–15GB | 4K from streaming services. Great quality-to-size ratio for 4K. |
| Bluray-2160p | 15–40GB | Re-encoded 4K from UHD Blu-ray. |
| Remux-2160p | 40–80GB | Full UHD Blu-ray quality. Massive files. |

### Choosing Your Profile

There's no single "right" answer—it depends on your storage, bandwidth, and how you watch:

- **Storage limited?** Stick to 720p or 1080p WEBDL. These offer good quality at reasonable sizes.
- **Have plenty of storage?** Consider 4K (2160p) for shows that benefit from it—nature documentaries, prestige dramas with cinematic visuals, etc.
- **Watch on phones/tablets mostly?** 1080p is usually indistinguishable from 4K on small screens.
- **Have a 4K TV and good home network?** 4K WEBDL is a sweet spot—noticeably better than 1080p without the massive file sizes of remuxes.

### Setting Up a Profile

1. Go to **Settings** > **Profiles**
2. Edit an existing profile or create a new one
3. Check the qualities you want Sonarr to download
4. Drag to set priority (higher = preferred when multiple are available)
5. Set **Cutoff** to the quality where Sonarr should stop upgrading (e.g., if set to Bluray-1080p, Sonarr won't replace a Bluray-1080p with a Remux)
6. Save

You can create multiple profiles for different use cases—perhaps a "4K" profile for cinematic shows and an "HD" profile for sitcoms where 4K doesn't matter.

## Add Your First TV Show

### Search and Add

1. Click **Add New** in the left menu
2. Search for a TV show by name
3. Select the correct show from results
4. Configure:

| Setting | Notes |
|---------|-------|
| Root Folder | `/tv` |
| Monitor | All Episodes (or First Season, if you want to test first) |
| Quality Profile | Whichever profile matches your preferences |
| Series Type | Standard (or Anime for anime series) |
| Season Folder | Yes |

5. Click **Add**

### Monitor vs Unmonitor

- **Monitored**: Sonarr will download new/missing episodes
- **Unmonitored**: Sonarr tracks but won't download

You can toggle monitoring per show or per season.

### Start Initial Search

After adding a show, click the **Search All** button (magnifying glass icon) to search for existing episodes.

> **Note:** Be patient on your first search. Depending on indexers, it may take time.

## Understanding Sonarr Workflow

1. You add a TV show
2. Sonarr monitors RSS feeds from indexers for new episodes
3. When a matching episode is found, Sonarr sends it to qBittorrent
4. qBittorrent downloads the file to `/downloads/complete/sonarr`
5. Sonarr detects the download is complete
6. Sonarr moves/renames the file to `/tv/<show name>/Season XX/`
7. Plex detects the new file and adds it to your library

## Troubleshooting

### No Indexers Available

1. Check Prowlarr connection:
   - Go to **Settings** > **General** > copy API Key
   - Verify it matches what's in Prowlarr
2. In Prowlarr, go to **Settings** > **Apps** > Sonarr > **Sync App Indexers**

### Downloads Not Starting

1. Check download client connection:
   - **Settings** > **Download Clients** > Test qBittorrent
2. Verify category exists in qBittorrent
3. Check VPN is still connected:
   ```bash
   docker exec nordlynx curl -s https://ipv4.icanhazip.com
   ```

### Downloads Complete But Not Importing

1. Check permissions:
   ```bash
   ls -la ~/downloads/complete/sonarr/
   ```
2. Verify root folder path is correct
3. Check **Activity** > **Queue** for import errors

### "Path does not exist" Errors

Make sure you're using the container paths:
- TV: `/tv` (not `/data/media/tv`)
- Downloads: `/downloads` (not `~/downloads`)

## Quality Upgrade Behavior

If you want Sonarr to upgrade existing files when better quality is available:

1. Go to **Settings** > **Profiles**
2. Edit your profile
3. Set **Upgrade Until** to your preferred maximum quality
4. Enable **Upgrades Allowed**

## Quick Reference

| Setting | Value |
|---------|-------|
| Sonarr URL | `http://<server-ip>:8989` |
| Root Folder (container) | `/tv` |
| Root Folder (host) | `/data/media/tv` |
| qBittorrent Category | `sonarr` |
| Download Client Host | `nordlynx` |

## Next Steps

Sonarr is configured for TV automation. Next, we'll configure Radarr for movies.

---

**Previous:** [Chapter 9: Configure Prowlarr](09-configure-prowlarr.md)

**Next:** [Chapter 11: Configure Radarr](11-configure-radarr.md)
