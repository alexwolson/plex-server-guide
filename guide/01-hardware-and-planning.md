# Chapter 1: Hardware and Planning

Before installing anything, let's make sure you have the right hardware and a clear plan.

## Hardware Requirements

### CPU: Intel Recommended

**Why Intel?** Hardware transcoding (converting video formats on-the-fly) is crucial for streaming. Intel's Quick Sync Video (QSV) is well-supported by Plex and works reliably on Linux.

#### Understanding Video Codecs and Transcoding

Video files use **codecs** (compression algorithms) to store video data efficiently. Common codecs include:

- **H.264 (AVC)** - The most common codec. Nearly everything supports it.
- **H.265 (HEVC)** - Newer, ~50% smaller files than H.264 at same quality. Common in 4K content.
- **VP9** - Google's codec, used heavily by YouTube.
- **AV1** - Newest codec, even better compression than HEVC. Growing adoption.

When a client device (phone, TV, browser) can't directly play a video's codec, Plex must **transcode** it - decode the original and re-encode it in a compatible format in real-time. This is computationally expensive.

**Hardware transcoding** offloads this work to dedicated circuits in your CPU's integrated graphics, allowing multiple simultaneous transcodes without breaking a sweat. Software transcoding uses raw CPU power and struggles with more than one or two streams.

#### Quick Sync Video (QSV) Codec Support

Not all Intel CPUs support all codecs. Here's what each generation can hardware encode AND decode:

| Generation | Architecture | H.264 | H.265 (HEVC) | VP9 | AV1 |
|------------|--------------|-------|--------------|-----|-----|
| 2nd-3rd | Sandy/Ivy Bridge | ✓ | - | - | - |
| 4th | Haswell | ✓ | - | - | - |
| 5th | Broadwell | ✓ | - | - | - |
| 6th | Skylake | ✓ | 8-bit only | - | - |
| 7th-10th | Kaby Lake → Comet Lake | ✓ | ✓ (10-bit) | decode only | - |
| 11th | Ice Lake / Tiger Lake | ✓ | ✓ (10-bit) | ✓ | decode only |
| 12th-14th | Alder Lake → Raptor Lake | ✓ | ✓ (10-bit) | ✓ | decode only |
| Arc GPUs | Alchemist | ✓ | ✓ | ✓ | ✓ |

**What this means in practice:**
- **7th gen (Kaby Lake) or newer** is the sweet spot - full H.264 and H.265/HEVC 10-bit support covers 95%+ of content
- **6th gen (Skylake)** works but struggles with HDR content (10-bit HEVC)
- **Older than 6th gen** can only transcode H.264, which is increasingly limiting as HEVC becomes standard
- **AV1 encoding** requires an Intel Arc GPU (discrete) if you need it

> **Warning: F-series and certain desktop CPUs have NO integrated graphics.** Models like i5-12400**F**, i7-13700**F**, etc. have the "F" suffix indicating no iGPU - these cannot do QSV transcoding at all. Similarly, some high-end desktop (HEDT) chips like X-series have no iGPU. Always verify your CPU has Intel UHD or Iris graphics.

#### Recommended CPUs

| Level | CPU Generation | Example CPUs | Notes |
|-------|---------------|--------------|-------|
| Minimum | 7th gen+ | i3-7100, Pentium G4560 | 1-2 simultaneous transcodes, full HEVC |
| Recommended | 10th gen+ | i3-10100, i5-10400 | 3-4 simultaneous transcodes |
| Overkill | 12th gen+ | i5-12400, i7-12700 | Many transcodes, VP9 support |

**AMD alternative:** AMD CPUs work but lack hardware transcoding equivalent to Intel QSV. You'll need a more powerful CPU for software transcoding, or add a dedicated GPU (AMD or NVIDIA).

**Used hardware:** Older Intel workstations (Dell OptiPlex, HP ProDesk, Lenovo ThinkCentre) are excellent budget options. A used i5-8500 workstation often costs less than $150 and handles HEVC perfectly.

### RAM: 8GB Minimum

| Amount | Use Case |
|--------|----------|
| 8GB | Minimum viable, may need to limit concurrent services |
| 16GB | Comfortable for all services with room to spare |
| 32GB+ | Overkill for most home servers |

The *arr applications (Sonarr, Radarr, Prowlarr) each use 200-500MB. Plex uses more during transcoding.

### Storage

**Single drive works fine.** You can run everything on one SSD or one HDD. A 1TB+ drive is enough to get started.

**SSD + HDD is recommended** if you want the best of both worlds:

| Drive | Purpose | Recommendation |
|-------|---------|----------------|
| SSD | OS, downloads, configs | 256GB minimum, 512GB recommended |
| HDD | Media library | 1TB minimum, 4TB+ recommended |

**Why two drives?** Torrent downloads involve lots of random read/write operations that HDDs handle poorly. Using an SSD for active downloads and moving completed files to the HDD gives better performance. But this is an optimization, not a requirement.

#### Storage Math

| Content Type | Typical Size |
|--------------|--------------|
| 1080p movie | 5-15 GB |
| 4K movie | 20-80 GB |
| TV episode (1080p) | 1-4 GB |
| TV season (10 episodes) | 10-40 GB |

A 4TB drive can hold roughly:
- 400+ movies at 1080p, or
- 100+ TV series, or
- 50 4K movies

### Network: Wired Ethernet

**Strongly recommended:** Connect your server via ethernet cable, not WiFi.

- Media streaming requires consistent bandwidth
- Docker networking can have issues over WiFi
- 1 Gbps ethernet is standard and sufficient

### Power and Noise

If the server will be in a living space:
- Consider noise levels (fans, hard drives)
- Look for cases with quiet fans
- Use 2.5" HDDs instead of 3.5" for less noise (but smaller capacity)

## Planning Checklist

Complete this checklist before starting the installation:

### 1. Hardware Ready

- [ ] Computer with Intel CPU (or AMD with GPU)
- [ ] At least 8GB RAM
- [ ] Storage: single drive (1TB+) or SSD + HDD combo
- [ ] Ethernet cable and router access
- [ ] Monitor and keyboard (for initial setup)

### 2. Network Information

Gather this information from your router:

- [ ] Router admin interface URL (usually `192.168.1.1` or `192.168.0.1`)
- [ ] Router admin password
- [ ] Your network's subnet (e.g., `192.168.1.x`)
- [ ] Available static IP or understand DHCP reservation

### 3. Accounts Created

- [ ] **NordVPN** - Active subscription with access to your account
- [ ] **Plex** - Account created at [plex.tv](https://plex.tv)

### 4. (Optional) Domain Planned

> **Note:** A domain is optional. Plex has built-in remote access that works without a domain. A domain gives you pretty URLs like `https://media.example.com` and lets you expose other services (Jellyseerr, Sonarr) externally with HTTPS.

If you want a custom domain:

- [ ] Domain name decided (e.g., `mymediaserver.com`)
- [ ] Budget for domain ($10-15/year typically)
- [ ] **Porkbun** (or other registrar) - Account ready for domain purchase

**Tip:** The `.stream` TLD is popular for media servers but any domain works.

### 5. Directory Structure Planned

Decide where your media will live:

```
/data/media/           # Media storage (second drive or folder on main drive)
├── movies/            # Movie library
├── tv/                # TV show library
└── homevideo/         # Personal videos (optional)

/home/your-username/
├── downloads/         # Active downloads
│   ├── complete/      # Finished downloads
│   └── incomplete/    # In-progress downloads
└── mediaserver/       # Service configurations
    └── config/
```

- [ ] Know your username on the server

## Example Builds

### Minimal Build (~$100)

- **Used Dell OptiPlex 7050** with i5-7500
- 8GB DDR4 RAM (included)
- 1TB HDD (included) - single drive setup

### Budget Build (~$200)

- **Used Dell OptiPlex 7050** with i5-7500
- 8GB DDR4 RAM (included)
- 256GB SSD + 4TB WD Blue HDD

### Mid-Range Build (~$400)

- **Used Dell OptiPlex 7080** with i5-10500
- 16GB DDR4 RAM
- 512GB NVMe SSD + 8TB WD Red Plus HDD

### New Build (~$600+)

- **Intel NUC or mini PC** with i5-12th gen
- 32GB DDR4 RAM
- 2TB NVMe SSD (single drive) or 1TB SSD + 12TB HDD

## Pre-Installation Tasks

Before installing Ubuntu:

### 1. Test the Hardware

Boot the computer and verify:
- CPU is detected correctly
- All RAM is recognized
- Storage devices appear

### 2. Update BIOS (Optional but Recommended)

Check the manufacturer's website for BIOS updates, especially for used hardware.

### 3. Configure BIOS Settings

Enter BIOS setup (usually F2, F12, or DEL during boot):

- **Enable virtualization** (Intel VT-x / AMD-V)
- **Disable Secure Boot** (can interfere with Docker)
- **Set boot order** to USB first (for Ubuntu installation)

### 4. Download Ubuntu

Download the **latest Ubuntu Server LTS** from [ubuntu.com/download/server](https://ubuntu.com/download/server).

Create a bootable USB drive using:
- [Balena Etcher](https://www.balena.io/etcher/) (easiest)
- [Rufus](https://rufus.ie/) (Windows)
- `dd` command (Linux/macOS)

## Quick Decisions Summary

Fill in these decisions before proceeding:

| Decision | Your Choice |
|----------|-------------|
| Server username | _____________ |
| Media storage path | `/data` (default) or _____________ |
| Domain name (optional) | _____________ |
| Static IP address | _____________ |

## Ready to Install

Once you have:
- Hardware assembled and tested
- Checklist completed
- Ubuntu USB drive ready

You're ready to install Ubuntu.

---

**Previous:** [Chapter 0: Introduction](00-introduction.md)

**Next:** [Chapter 2: Install Ubuntu](02-install-ubuntu.md)
