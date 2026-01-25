# Chapter 5: Storage Setup

This chapter covers setting up the directory structure for your media library and downloads.

## Overview

We'll create two directory structures:

1. **Media directories** (on HDD) - Long-term storage for your movies and TV shows
2. **Download directories** (on SSD) - Temporary storage for active downloads

## Why Separate Storage?

| Location | Purpose | Why? |
|----------|---------|------|
| SSD (downloads) | Active torrents | Torrenting requires lots of random I/O; SSDs handle this well |
| HDD (media) | Completed media | Sequential access for streaming; HDDs offer more capacity per dollar |

The *arr applications (Sonarr/Radarr) automatically move completed downloads from the SSD to the HDD.

## Prerequisites

- Ubuntu installed with SSD for root filesystem
- HDD available (may need mounting)

## Part 1: Mount Your HDD (If Needed)

If your HDD is already mounted at `/data`, skip to [Part 2](#part-2-create-media-directories).

### Find Your HDD

```bash
lsblk
```

Look for your HDD. It will be something like `sdb` or `sdc` (not `sda` which is usually your SSD).

Example output:
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 476.9G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
└─sda2   8:2    0 476.4G  0 part /
sdb      8:16   0   3.6T  0 disk
└─sdb1   8:17   0   3.6T  0 part
```

In this example, `sdb1` is the HDD partition.

### Check if HDD Has a Filesystem

```bash
sudo blkid /dev/sdb1
```

If it shows a filesystem type (like `ext4` or `ntfs`), the drive is formatted.

### Format the HDD (If Needed)

> **Warning:** This erases all data on the drive!

If the drive is new or you want to start fresh:

```bash
sudo mkfs.ext4 -L mediastore /dev/sdb1
```

### Create Mount Point

```bash
sudo mkdir -p /data
```

### Get the UUID

```bash
sudo blkid /dev/sdb1 | grep -oP 'UUID="\K[^"]+'
```

Copy this UUID for the next step.

### Add to fstab for Automatic Mounting

```bash
# Replace YOUR-UUID-HERE with the actual UUID from above
echo 'UUID=YOUR-UUID-HERE /data ext4 defaults 0 2' | sudo tee -a /etc/fstab
```

Or edit fstab manually:
```bash
sudo nano /etc/fstab
```

Add this line (with your actual UUID):
```
UUID=your-uuid-here /data ext4 defaults 0 2
```

### Mount the Drive

```bash
sudo mount -a
```

### Verify Mount

```bash
df -h /data
```

You should see your HDD mounted at `/data`.

## Part 2: Create Media Directories

Create the directory structure for your media library:

```bash
sudo mkdir -p /data/media/{movies,tv,homevideo}
```

This creates:
```
/data/media/
├── movies/      # Feature films
├── tv/          # TV series
└── homevideo/   # Personal videos (optional)
```

### Set Ownership

Set ownership to your user:

```bash
sudo chown -R $USER:$USER /data/media
```

### Set Permissions

```bash
chmod -R 755 /data/media
```

### Verify

```bash
ls -la /data/media/
```

Expected output:
```
drwxr-xr-x movies
drwxr-xr-x tv
drwxr-xr-x homevideo
```

## Part 3: Create Download Directories

Create the download directory structure on your SSD:

```bash
mkdir -p ~/downloads/{incomplete,complete}
```

This creates:
```
~/downloads/
├── incomplete/    # In-progress downloads
└── complete/      # Finished downloads (awaiting import)
```

### Verify

```bash
ls -la ~/downloads/
```

Expected output:
```
drwxrwxr-x complete
drwxrwxr-x incomplete
```

## Part 4: Create Mediaserver Config Directory

This is where all your Docker service configurations will live:

```bash
mkdir -p ~/mediaserver/config
```

## Directory Reference

Here's a summary of all the directories we've created:

| Directory | Purpose | Location |
|-----------|---------|----------|
| `/data/media/movies` | Movie library | HDD |
| `/data/media/tv` | TV show library | HDD |
| `/data/media/homevideo` | Personal videos | HDD |
| `~/downloads/complete` | Finished downloads | SSD |
| `~/downloads/incomplete` | In-progress downloads | SSD |
| `~/mediaserver/config` | Service configurations | SSD |

## Application Paths

When configuring applications later, use these paths:

### Plex Libraries

| Library Type | Path |
|--------------|------|
| Movies | `/data/media/movies` |
| TV Shows | `/data/media/tv` |
| Home Videos | `/data/media/homevideo` |

### Sonarr/Radarr Root Folders

| Application | Root Folder |
|-------------|-------------|
| Radarr (movies) | `/data/media/movies` |
| Sonarr (TV) | `/data/media/tv` |

### qBittorrent Paths

| Setting | Path |
|---------|------|
| Default save path | `/downloads/complete` |
| Incomplete downloads | `/downloads/incomplete` |

> **Note:** The paths in qBittorrent will be different from the host because they're mapped through Docker volumes. We'll cover this in [Chapter 7](07-docker-compose-stack.md).

## Troubleshooting

### HDD Not Showing Up

1. Check if the drive is detected:
   ```bash
   sudo fdisk -l
   ```

2. Check for SMART errors:
   ```bash
   sudo apt install smartmontools
   sudo smartctl -a /dev/sdb
   ```

### Permission Denied

If you get permission errors:

```bash
# Check ownership
ls -la /data/media

# Fix ownership
sudo chown -R $USER:$USER /data/media
```

### fstab Entry Wrong

If the system doesn't boot after editing fstab:

1. You'll see an emergency mode prompt
2. Press Enter to get a shell
3. Edit fstab: `nano /etc/fstab`
4. Fix or comment out the problematic line
5. Reboot: `reboot`

## Next Steps

Storage is configured. Next, we'll install Plex Media Server for streaming your media library.

---

**Previous:** [Chapter 4: SSH Security](04-ssh-security.md)

**Next:** [Chapter 6: Install Plex](06-install-plex.md)
