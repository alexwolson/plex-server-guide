# Chapter 12: Configure Bazarr (Optional)

[Bazarr](https://github.com/morpheus65535/bazarr) automatically downloads subtitles for your movies and TV shows. If you watch content in other languages or prefer having subtitles available, this service is for you.

> **This chapter is optional.** If you don't need subtitles, skip to [Chapter 13](13-configure-jellyseerr.md) or [Chapter 14](14-domain-and-dns.md).

## Understanding Subtitle Types

Before configuring Bazarr, it helps to understand the different types of subtitles you'll encounter:

### Regular Subtitles

Standard subtitles that display dialogue only. These assume you can hear the audio and just need the dialogue translated or transcribed. They don't include sound descriptions—no *[door creaks]* or *[tense music]*—just what characters say.

Regular subtitles are typically **verbatim** (word-for-word what's spoken) when in the original language, but may be **paraphrased** when translated to fit reading speed or cultural context.

### SDH (Subtitles for the Deaf and Hard of Hearing)

SDH subtitles include dialogue plus non-speech audio information:
- Sound effects: *[door creaks]*, *[phone ringing]*
- Music: *[tense orchestral music]*, *[upbeat pop song playing]*
- Speaker identification: *JOHN: Hello* or *(whispering)*
- Off-screen sounds: *[footsteps approaching]*, *[dog barking in distance]*

SDH subtitles are **verbatim**—they transcribe exactly what's said, including filler words, stuttering, and overlapping dialogue. They're designed for viewers who can't hear the audio at all.

SDH subtitles are useful if you're watching with the sound off, in a noisy environment, or have hearing difficulties.

### CC (Closed Captions)

Technically, CC refers to subtitles embedded in a broadcast signal (the "closed" means they can be turned on/off). In practice, CC and SDH are often used interchangeably—both include sound descriptions and are verbatim transcriptions. When Bazarr or subtitle sites say "CC," they usually mean SDH-style subtitles.

### Verbatim vs Paraphrased: Quick Summary

| Type | Dialogue | Sound descriptions | Verbatim? |
|------|----------|-------------------|-----------|
| Regular (same language) | Yes | No | Usually yes |
| Regular (translated) | Yes | No | Often paraphrased |
| SDH / CC | Yes | Yes | Yes |
| Forced | Foreign dialogue only | No | Usually yes |

### Forced Subtitles

Forced subtitles only appear when necessary—typically for:
- Foreign language dialogue in an otherwise English film (e.g., when characters speak Elvish in Lord of the Rings)
- On-screen text that needs translation (signs, letters, etc.)

These are meant to be shown *in addition to* the main audio, not as a replacement for it. In Bazarr, you'll usually want to **exclude** forced subtitles unless you specifically want only these minimal translations.

### HI (Hearing Impaired)

HI is essentially another term for SDH—subtitles that include sound descriptions. In Bazarr settings, you can choose to:
- **Include**: Prefer subtitles with sound descriptions
- **Exclude**: Prefer dialogue-only subtitles
- **Only**: Only download HI/SDH subtitles

### Which Should You Choose?

- **Watching in your native language, just want backup subtitles**: Regular (non-HI) subtitles
- **Often watch with sound off or low**: SDH/HI subtitles
- **Only want translations for foreign dialogue**: Forced subtitles
- **Hearing difficulties**: SDH/HI subtitles

## Do You Need Bazarr?

Before setting up Bazarr, consider whether you actually need it:

**Many downloads already include subtitles.** Torrent releases—especially from quality release groups—often come with subtitle files (`.srt`) included, or have subtitles embedded directly in the video file (particularly common with MKV containers). You may find that most of your library already has subtitles without any extra effort.

**Plex can find subtitles on demand.** When watching something in Plex, you can click the subtitle icon and select "Search" to find subtitles from OpenSubtitles. This is manual (you do it per video), but it works well for occasional use. You don't need a separate service if you only occasionally need subtitles.

**Bazarr is useful when:**
- You want subtitles automatically downloaded for everything
- You watch a lot of non-English content
- You prefer a specific subtitle source or style
- You want subtitles ready before you start watching

If you only need subtitles occasionally, you can skip Bazarr and use Plex's built-in search instead.

## Overview

Bazarr:
- Connects to Sonarr and Radarr to know what media you have
- Searches subtitle providers for matching subtitles
- Downloads and renames subtitles to match your media files
- Can automatically fetch subtitles for new content

## Prerequisites

- Docker Compose stack running ([Chapter 7](07-docker-compose-stack.md))
- Sonarr configured ([Chapter 10](10-configure-sonarr.md))
- Radarr configured ([Chapter 11](11-configure-radarr.md))

## Access Bazarr

Open your browser:
```
http://<server-ip>:6767
```

## Initial Setup Wizard

On first access, Bazarr shows a setup wizard.

### Step 1: General Settings

1. **Subtitles Directory**: Leave blank (stores with media)
2. Enable **Single Language** if you only want one language
3. Click **Next**

### Step 2: Languages

1. Click **Add New Profile**
2. Select your language(s):
   - **Language**: English (or your preferred language)
   - **Forced**: Exclude (unless you want forced subs only)
   - **Hi (Hearing Impaired)**: Exclude or Include based on preference
3. Click **Save**
4. Click **Next**

### Step 3: Providers

You need to configure subtitle providers. Popular options:

#### OpenSubtitles.com (Recommended)

1. Click **OpenSubtitles.com**
2. Create account at [opensubtitles.com](https://www.opensubtitles.com) if needed
3. Enter your username and password
4. Click **Save**

#### Other Providers (Optional)

Consider adding backup providers:
- **Subscene** - Good for international content
- **Podnapisi** - European languages
- **YIFY Subtitles** - Movie focused

5. Click **Next** when done

### Step 4: Sonarr Connection

1. **Hostname or IP Address**: `sonarr`
2. **Port**: `8989`
3. **API Key**: Copy from Sonarr (**Settings** > **General**)
4. Click **Test**
5. If successful, click **Next**

### Step 5: Radarr Connection

1. **Hostname or IP Address**: `radarr`
2. **Port**: `7878`
3. **API Key**: Copy from Radarr (**Settings** > **General**)
4. Click **Test**
5. If successful, click **Save**

The wizard is complete. Bazarr will now sync with Sonarr and Radarr.

## Configure Language Profile

If you skipped or need to modify:

1. Go to **Settings** > **Languages**
2. Click **Add New Profile**
3. Configure:

| Setting | Recommendation |
|---------|---------------|
| Profile Name | Main |
| Cutoff | Your primary language |
| Languages | Add preferred languages in order |

4. Click **Save**

### Apply Profile to Libraries

1. Go to **Settings** > **Languages**
2. Under **Default Settings**:
   - **Series Default Profile**: Select your profile
   - **Movies Default Profile**: Select your profile
3. Click **Save**

## Configure Providers

For better subtitle coverage, add multiple providers:

1. Go to **Settings** > **Providers**
2. Click **Add Provider**
3. Configure each provider:

### OpenSubtitles.com Setup

| Setting | Value |
|---------|-------|
| Username | Your account username |
| Password | Your account password |
| VIP | Uncheck unless you have VIP subscription |

### Provider Recommendations

| Provider | Best For |
|----------|----------|
| OpenSubtitles.com | General use, large database |
| Subscene | Non-English content |
| Addic7ed | TV shows |
| YIFY Subtitles | Movies |

## Sync Your Library

After setup, Bazarr needs to scan your libraries:

1. Go to **Series** - Bazarr shows your TV shows
2. Go to **Movies** - Bazarr shows your movies

Bazarr will automatically search for missing subtitles.

## Manual Subtitle Download

To manually download subtitles:

1. Click on a movie or episode
2. Click **Search** (magnifying glass)
3. Browse available subtitles
4. Click **Download** on your preferred one

## Automatic Downloads

Bazarr can automatically download subtitles for new content:

1. Go to **Settings** > **Subtitles**
2. Under **Automatic**:
   - Enable **Search Enabled**
   - Set **Search Days Limit** (how far back to search)
3. Click **Save**

## Fine-Tune Settings

### Subtitle Synchronization

Bazarr can auto-sync subtitles with audio:

1. Go to **Settings** > **Subtitles**
2. Enable **Automatic Subtitles Synchronization**
3. This requires ffmpeg (included in the container)

### Anti-Captcha (Optional)

Some providers require captcha solving:

1. Go to **Settings** > **Anti-Captcha**
2. Choose a provider (Anti-Captcha or DeathByCaptcha)
3. Enter API credentials
4. This helps with providers that rate-limit

## Troubleshooting

### No Subtitles Found

1. Check providers are configured correctly
2. Verify the provider has subtitles available
3. Try adding more providers
4. Check if the release matches available subtitles

### Subtitles Out of Sync

1. Click on the subtitle in Bazarr
2. Click **Sync** to try automatic synchronization
3. If that fails, try a different subtitle release

### Connection Errors

If Sonarr/Radarr connection fails:

1. Verify container names are correct:
   - Sonarr: `sonarr`
   - Radarr: `radarr`
2. Check API keys are correct
3. Verify containers are running:
   ```bash
   docker ps | grep -E "(sonarr|radarr)"
   ```

### Provider Errors

1. Check your credentials
2. Some providers have rate limits - wait and retry
3. Consider adding more providers as backup

## Quick Reference

| Setting | Value |
|---------|-------|
| Bazarr URL | `http://<server-ip>:6767` |
| Sonarr Host (internal) | `sonarr` |
| Radarr Host (internal) | `radarr` |

## Next Steps

Bazarr is configured for automatic subtitles. Next is Jellyseerr for letting others request content.

---

**Previous:** [Chapter 11: Configure Radarr](11-configure-radarr.md)

**Next:** [Chapter 13: Configure Jellyseerr (Optional)](13-configure-jellyseerr.md)
