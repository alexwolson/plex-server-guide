# Chapter 1: Hardware and Planning

Before installing anything, let's make sure you have the right hardware and a clear plan.

## Hardware Requirements

### CPU: Intel Recommended

**Why Intel?** Hardware transcoding (converting video formats on-the-fly) is crucial for streaming. Intel's Quick Sync Video (QSV) is well-supported by Plex and works reliably on Linux.

| Level | CPU Generation | Example CPUs | Notes |
|-------|---------------|--------------|-------|
| Minimum | 7th gen+ | i3-7100, Pentium G4560 | 1-2 simultaneous transcodes |
| Recommended | 10th gen+ | i3-10100, i5-10400 | 3-4 simultaneous transcodes |
| Overkill | 12th gen+ | i5-12400, i7-12700 | Many transcodes, HEVC support |

**AMD alternative:** AMD CPUs work but lack hardware transcoding equivalent to Intel QSV. You'll need a more powerful CPU for software transcoding, or add a dedicated GPU.

**Used hardware:** Older Intel workstations (Dell OptiPlex, HP ProDesk, Lenovo ThinkCentre) are excellent budget options. A used i5-8500 workstation often costs less than $150.

### RAM: 8GB Minimum

| Amount | Use Case |
|--------|----------|
| 8GB | Minimum viable, may need to limit concurrent services |
| 16GB | Comfortable for all services with room to spare |
| 32GB+ | Overkill for most home servers |

The *arr applications (Sonarr, Radarr, Prowlarr) each use 200-500MB. Plex uses more during transcoding.

### Storage: SSD + HDD

**You need two types of storage:**

#### 1. SSD (Fast) - For OS, downloads, and configs
- **Minimum:** 256GB
- **Recommended:** 512GB
- **Purpose:** Operating system, active downloads, service configurations

#### 2. HDD (Large) - For media library
- **Size:** Depends on your library (1TB minimum, 4TB+ recommended)
- **Purpose:** Long-term storage of movies and TV shows
- **Speed:** 5400 RPM is fine, 7200 RPM is better

**Why both?** Torrent downloads involve lots of random read/write operations that HDDs handle poorly. Using an SSD for downloads and moving completed files to the HDD gives you the best of both worlds.

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
- [ ] SSD (256GB+) for OS and downloads
- [ ] HDD for media storage
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
/data/media/           # HDD mount point
├── movies/            # Movie library
├── tv/                # TV show library
└── homevideo/         # Personal videos (optional)

/home/your-username/
├── downloads/         # SSD
│   ├── complete/      # Finished downloads
│   └── incomplete/    # In-progress downloads
└── mediaserver/       # SSD
    └── config/        # Service configurations
```

- [ ] Know where your HDD will be mounted
- [ ] Know your username on the server

## Example Builds

### Budget Build (~$150)

- **Used Dell OptiPlex 7050** with i5-7500
- 8GB DDR4 RAM (included)
- 256GB SSD (included or $25)
- 4TB WD Blue HDD ($80)

### Mid-Range Build (~$400)

- **Used Dell OptiPlex 7080** with i5-10500
- 16GB DDR4 RAM
- 512GB NVMe SSD
- 8TB WD Red Plus HDD

### New Build (~$600+)

- **Intel NUC or mini PC** with i5-12th gen
- 32GB DDR4 RAM
- 1TB NVMe SSD
- 12TB Seagate Exos HDD

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
| HDD mount point | `/data` or _____________ |
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
