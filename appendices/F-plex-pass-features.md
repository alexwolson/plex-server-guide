# Appendix F: Plex Pass and Premium Features

This guide mentions several Plex features that require a paid subscription. Here's what's free vs. paid.

## Subscription Options

### Remote Watch Pass

A simpler subscription that only enables:
- **Remote streaming** of personal content from any Plex Media Server you have access to

"Remote" means not on the same local network as the server. This subscription doesn't include other premium features.

### Plex Pass

The full premium subscription includes everything in Remote Watch Pass plus:

- **Hardware-accelerated transcoding** - Use Intel QSV, NVIDIA NVENC, or AMD VCE for efficient video conversion
- **Skip Intro** - Automatically skip TV episode intros
- **Skip Credits** - Skip to the next episode automatically
- **Mobile Sync** - Download content for offline viewing on mobile devices
- **Plex Dash** - Mobile app for server management
- **HDR to SDR tone mapping** - Preserve colors when transcoding HDR content
- **Trailers and extras** - Stream interviews, behind-the-scenes, etc.
- **Lyrics** - Display lyrics from LyricFind in your music library
- **Plex Home** - Invite family members with full Plex accounts (not just managed users)
- **Premium Plexamp features** - Sonic Analysis, Sonic Sage, Guest DJ, and more
- **DVR Recording** - Record over-the-air broadcasts with a compatible tuner
- **Early access** - Preview new apps and features

## What's Free

These features work without any subscription:

- Running a Plex Media Server
- Local streaming (same network as server)
- Basic remote access via relay (limited to ~2 Mbps)
- Organizing and managing your library
- Sharing libraries with other Plex users
- Free ad-supported movies and TV shows

## Features Used in This Guide

| Feature | Subscription Required | Where It's Mentioned |
|---------|----------------------|----------------------|
| Hardware transcoding (QSV) | Plex Pass | [Chapter 6: Install Plex](../guide/06-install-plex.md) |
| Full-speed remote streaming | Plex Pass or Remote Watch Pass | [Chapter 18: Plex Remote Access](../guide/18-plex-remote-access.md) |
| Mobile Sync (offline downloads) | Plex Pass | [Chapter 18: Plex Remote Access](../guide/18-plex-remote-access.md) |
| Relay priority | Plex Pass | [Chapter 18: Plex Remote Access](../guide/18-plex-remote-access.md) |

## Do You Need Plex Pass?

**You probably want Plex Pass if:**
- You stream remotely frequently
- Your viewers' devices can't direct play your content (transcoding needed)
- You want Skip Intro for TV shows
- You want mobile offline downloads

**You can skip it if:**
- You mostly watch on your local network
- Your devices can direct play your content formats
- You're okay with relay speeds (~2 Mbps) when direct connection fails
