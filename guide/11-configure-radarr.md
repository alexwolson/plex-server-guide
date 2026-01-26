# Chapter 11: Configure Radarr

[Radarr](https://github.com/Radarr/Radarr) automates movie downloads. It works similarly to Sonarr but for movies instead of TV shows.

## Overview

In this chapter, we'll:
- Set up authentication
- Configure media management
- Add root folder
- Connect to qBittorrent
- Verify indexers from Prowlarr
- Add your first movie

## Prerequisites

- Docker Compose stack running ([Chapter 7](07-docker-compose-stack.md))
- qBittorrent configured ([Chapter 8](08-configure-qbittorrent.md))
- Prowlarr configured with Radarr connection ([Chapter 9](09-configure-prowlarr.md))

## Access Radarr

Open your browser:
```
http://<server-ip>:7878
```

## Initial Setup

### Set Up Authentication

1. Go to **Settings** > **General**
2. Under **Security**, set:
   - **Authentication**: Forms (Login Page)
   - **Username**: Your chosen username
   - **Password**: A strong password
3. Click **Save Changes**

Log in with your new credentials.

## Configure Media Management

### Set Up File Naming

1. Go to **Settings** > **Media Management**
2. Enable **Rename Movies**
3. Configure naming format (or use default):

**Standard Movie Format:**
```
{Movie CleanTitle} {(Release Year)} {imdb-{ImdbId}} {edition-{Edition Tags}} {[Custom Formats]}{[Quality Full]}{[MediaInfo 3D]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[Mediainfo AudioLanguages]}{-Release Group}
```

**Movie Folder Format:**
```
{Movie CleanTitle} ({Release Year}) {imdb-{ImdbId}}
```

4. Click **Save Changes**

### File Management Settings

1. Enable **Unmonitor Deleted Movies** (optional)
2. Under **Importing**, consider:
   - **Skip Free Space Check**: Disable (leave unchecked)
   - **Use Hardlinks instead of Copy**: Enable if downloads and media are on same filesystem

## Add Root Folder

1. Go to **Settings** > **Media Management**
2. Click **Add Root Folder**
3. Navigate to `/movies` and select it
4. Click **OK**

> **Note:** `/movies` in the container maps to `/data/media/movies` on your host.

## Connect Download Client

1. Go to **Settings** > **Download Clients**
2. qBittorrent may already be synced from Prowlarr
3. If not, click **+** and add:

| Setting | Value |
|---------|-------|
| Name | `qBittorrent` |
| Host | `nordlynx` |
| Port | `8080` |
| Username | `admin` |
| Password | (your qBittorrent password) |
| Category | `radarr` |

4. Click **Test** then **Save**

> **Important:** Make sure the category is `radarr`, not `sonarr`.

## Verify Indexers

1. Go to **Settings** > **Indexers**
2. Confirm indexers were synced from Prowlarr
3. If empty, sync from Prowlarr

## Configure Quality Profiles

Quality profiles determine what video quality Radarr downloads. Go to **Settings** > **Profiles** to view and edit them.

### Understanding Movie Quality

The quality you choose is a trade-off between file size and visual fidelity. Movies generally benefit more from higher quality than TV shows—a sweeping landscape shot in a film is more noticeable at 4K than a sitcom filmed on a studio set.

| Quality | Size | What It Is |
|---------|------|------------|
| WEBDL-1080p | 3–8 GB | Ripped from streaming services. Clean quality, reasonable size. |
| WEBRip-1080p | 3–8 GB | Screen-captured from streaming. Slightly lower quality than WEBDL. |
| Bluray-1080p | 5–15 GB | Re-encoded from Blu-ray disc. Often better than streaming for live-action. |
| Remux-1080p | 20–40 GB | Full Blu-ray, no re-encoding. Reference quality but large files. |
| WEBDL-2160p | 10–25 GB | 4K from streaming. Excellent quality-to-size ratio for 4K content. |
| Bluray-2160p | 20–50 GB | Re-encoded from UHD Blu-ray. High quality 4K. |
| Remux-2160p | 50–80 GB | Full UHD Blu-ray quality. The best available, but massive files. |

### Choosing Your Profile

There's no universal "best" setting—it depends on your priorities:

- **Storage is limited?** 1080p WEBDL or Bluray offers excellent quality at manageable sizes.
- **Have plenty of storage?** 4K (2160p) is increasingly available and looks noticeably better on modern displays. WEBDL-2160p gives you 4K quality without the huge file sizes of Blu-ray encodes.
- **Collecting films you'll rewatch?** Consider Bluray or Remux quality for your favorites.
- **Just want something watchable?** 1080p WEBDL is perfectly good for casual viewing.

For visually impressive films (sci-fi epics, nature documentaries, animated features), the jump to 4K is often worth it. For dialogue-heavy dramas, 1080p is usually sufficient.

### Setting Up a Profile

1. Go to **Settings** > **Profiles**
2. Edit an existing profile or create a new one
3. Check the qualities you want Radarr to accept
4. Drag to set priority (higher = preferred when multiple are available)
5. Set **Cutoff** to the quality where Radarr stops upgrading
6. Save

You might create multiple profiles—"4K" for films where visuals matter, and "HD" for everything else.

## Add Your First Movie

### Search and Add

1. Click **Add New** in the left menu
2. Search for a movie by name
3. Select the correct movie from results
4. Configure:

| Setting | Notes |
|---------|-------|
| Root Folder | `/movies` |
| Monitor | Movie |
| Minimum Availability | Released (avoids low-quality cam recordings) |
| Quality Profile | Whichever profile matches your preferences |

5. Click **Add Movie** (or **Add Movie + Search** to search immediately)

### Start Search

If you didn't click "Add Movie + Search":
1. Find the movie in your library
2. Click on it
3. Click the **Search** button (magnifying glass)

## Minimum Availability Options

| Option | Description |
|--------|-------------|
| Announced | Search as soon as movie is announced |
| In Cinemas | Search when movie is in theaters |
| Released | Search when physically/digitally released |

**Recommended:** "Released" to avoid low-quality cam recordings.

## Bulk Import Existing Movies

If you already have movies in `/data/media/movies`:

1. Go to **Library** > **Import**
2. Click **Start Import**
3. Select `/movies`
4. Radarr will scan and match your existing movies
5. Review matches and click **Import**

## Understanding Radarr Workflow

1. You add a movie (or Jellyseerr sends a request)
2. Radarr searches indexers for the movie
3. If found meeting quality requirements, sent to qBittorrent
4. qBittorrent downloads to `/downloads/complete/radarr`
5. Radarr detects completion
6. Radarr moves/renames to `/movies/<Movie Name (Year)>/`
7. Plex detects and adds to library

## Troubleshooting

### Movie Shows "Missing" But Exists

The movie file might not match Radarr's naming:
1. Click on the movie
2. Click **Manual Import**
3. Navigate to the file location
4. Select and import

### Downloads Complete But Won't Import

1. Check download client settings
2. Verify category matches (`radarr`)
3. Check **Activity** > **Queue** for errors
4. Verify permissions on download folder

### "Root folder does not exist"

Make sure you're using container paths:
- Use `/movies` (not `/data/media/movies`)

### Movie Not Found in Search

1. Check the movie exists in TMDb (The Movie Database)
2. Try searching by IMDb ID
3. Verify indexers have the movie available

## Quality Upgrades

To allow Radarr to upgrade existing movies:

1. Go to **Settings** > **Profiles**
2. Edit your profile
3. Enable **Upgrades Allowed**
4. Set **Upgrade Until** to your maximum quality

## Lists (Optional)

Radarr can automatically add movies from lists:

1. Go to **Settings** > **Lists**
2. Click **+** to add a list
3. Options include:
   - Plex Watchlist
   - Trakt Popular/Trending
   - IMDb Lists

## Quick Reference

| Setting | Value |
|---------|-------|
| Radarr URL | `http://<server-ip>:7878` |
| Root Folder (container) | `/movies` |
| Root Folder (host) | `/data/media/movies` |
| qBittorrent Category | `radarr` |
| Download Client Host | `nordlynx` |

## Next Steps

Radarr is configured for movie automation. The next chapters cover optional services:
- **Bazarr** - Automatic subtitles
- **Jellyseerr** - Request management for users

---

**Previous:** [Chapter 10: Configure Sonarr](10-configure-sonarr.md)

**Next:** [Chapter 12: Configure Bazarr (Optional)](12-configure-bazarr.md)
