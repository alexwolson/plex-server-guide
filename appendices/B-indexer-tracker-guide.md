# Appendix B: Understanding Indexers and Trackers

Indexers are search engines that help Sonarr, Radarr, and Prowlarr find content. This appendix explains how they work and how to add them.

## Legal Disclaimer

**Important:** Indexers and trackers can be used to find both legal and illegal content. You are responsible for:

- Ensuring you have the right to download content
- Complying with copyright laws in your jurisdiction
- Following the terms of service of any indexer you use

This guide explains how the technology works. What you do with it is your responsibility.

## Understanding the Terms

### Indexer

An indexer is a website that catalogs available content and provides search functionality. Think of it as a specialized search engine.

- Stores metadata about available downloads
- Provides search API for applications like Prowlarr
- May require account/membership

### Tracker

A tracker coordinates connections between peers sharing files via BitTorrent.

- Helps downloaders find uploaders
- Tracks who has what files
- Private trackers require membership

### Usenet

An alternative to torrents:
- Requires paid subscription to a Usenet provider
- Content stored on servers, not peer-to-peer
- Generally faster and more anonymous
- Requires additional setup (not covered in this guide)

## Types of Indexers

### Public Indexers

- No account required
- Anyone can search
- Often have ads and lower quality
- Higher risk of fake/malware content
- Examples: (many exist, quality varies)

### Semi-Private Indexers

- Free registration required
- May have rate limits
- Better content quality than public
- Often require ratio maintenance

### Private Trackers

- Invitation only
- Strict rules and ratio requirements
- Highest quality content
- Community-focused
- Hard to join but worth it

## Adding Indexers to Prowlarr

### Access Prowlarr

```
http://<server-ip>:9696
```

### Add an Indexer

1. Go to **Indexers**
2. Click the **+** button
3. Browse or search for an indexer
4. Configure settings (varies by indexer)
5. Test the connection
6. Save

### Common Settings

| Setting | Purpose |
|---------|---------|
| API Key | Authentication (some indexers) |
| Username/Password | Login credentials |
| Passkey | Unique ID for private trackers |
| Base URL | Indexer's website (usually auto-filled) |

## Sync to Sonarr/Radarr

After adding indexers to Prowlarr:

1. Go to **Settings** > **Apps**
2. Click on Sonarr
3. Click **Sync App Indexers**
4. Repeat for Radarr

Indexers will now appear in Sonarr/Radarr settings.

## Private Tracker Basics

If you're interested in private trackers:

### How to Join

1. **Open signups** - Rare, watch tracker forums
2. **Invites** - Get invited by existing member
3. **Interview** - Some trackers have IRC interviews
4. **Application** - Fill out an application

### Maintaining Your Account

| Requirement | Description |
|-------------|-------------|
| Ratio | Upload/download ratio (often 1:1 minimum) |
| Activity | Regular login/downloads |
| Seeding | Keep files seeding for minimum time |
| Rules | Follow tracker-specific rules |

### Tips for Good Standing

- **Seed everything** - Don't hit-and-run
- **Use a seedbox** (optional) - Dedicated server for seeding
- **Upload content** - Contribute back
- **Follow rules** - Read the wiki/FAQ

## Indexer Categories

Indexers often have categories for different content:

| Category | Content Type |
|----------|--------------|
| 2000+ | Movies |
| 5000+ | TV Shows |
| 3000+ | Audio |
| 1000+ | PC/Games |

Prowlarr maps these to Sonarr/Radarr automatically.

## Troubleshooting Indexers

### No Results

1. Check indexer is enabled
2. Test indexer in Prowlarr
3. Verify categories are correct
4. Try searching manually on the indexer's website

### Rate Limited

- Reduce search frequency
- Add multiple indexers to spread load
- Consider indexer with higher limits

### Authentication Failed

- Verify credentials are correct
- Check if account is active
- Re-authenticate if needed

### Indexer Down

- Check indexer's website
- Check status pages/Discord
- Use backup indexers

## Recommended Setup

### Minimum

- 2-3 indexers for redundancy
- At least one that indexes TV and one for movies

### Better

- 5-10 indexers
- Mix of public and semi-private
- Different sources for different content types

### Best

- 1-2 good private trackers
- Several backup indexers
- Usenet for redundancy

## Search Flow

```
User Request (Jellyseerr)
        |
        v
   Sonarr/Radarr
        |
        v
     Prowlarr
        |
        +---> Indexer 1 ---> Results
        |
        +---> Indexer 2 ---> Results
        |
        +---> Indexer 3 ---> Results
        |
        v
   Best match selected
        |
        v
   qBittorrent downloads
```

## Quality and Release Groups

Indexers provide information about release quality:

### Quality Labels

| Label | Quality |
|-------|---------|
| CAM | Camera recording (avoid) |
| TS/TC | Telesync (poor) |
| HDTV | TV recording |
| WEB-DL | Streaming download |
| WEBRip | Streaming capture |
| Bluray | Disc source |
| Remux | Untouched disc |

### Trusted Release Groups

Over time, you'll learn which release groups produce quality content. Sonarr/Radarr can prefer specific groups.

## Security Considerations

### Protecting Yourself

1. **Use VPN** - Always use VPN for torrent traffic
2. **Private trackers** - Lower legal risk than public
3. **Usenet** - More anonymous than torrents
4. **Avoid suspicious files** - Check comments/reputation

### What NOT to Do

- Download obviously illegal content
- Share your tracker invites carelessly
- Ignore ratio requirements
- Use trackers without VPN

## Quick Reference

| Term | Definition |
|------|------------|
| Indexer | Search engine for content |
| Tracker | Coordinates torrent connections |
| Ratio | Upload ÷ Download |
| Seedbox | Remote server for downloading/seeding |
| Usenet | Alternative to torrents |
| NZB | Usenet download file |

## Further Reading

- [r/trackers](https://reddit.com/r/trackers) - Private tracker community
- [r/usenet](https://reddit.com/r/usenet) - Usenet community
- Individual indexer wikis and forums

## Next Steps

After adding indexers to Prowlarr, return to:
- [Chapter 9: Configure Prowlarr](../guide/09-configure-prowlarr.md)
- [Chapter 10: Configure Sonarr](../guide/10-configure-sonarr.md)
