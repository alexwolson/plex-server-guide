# Chapter 5: Storage Setup

This chapter covers setting up the directory structure for your media library and downloads.

## Choose Your Setup

**Pick the option that matches your hardware:**

- **[Option A: Single Drive](#option-a-single-drive-setup)** - One SSD or HDD for everything
- **[Option B: Two Drives](#option-b-two-drive-setup)** - SSD for downloads + HDD for media storage

Both work great. Two drives offer better performance for torrenting, but a single drive is simpler and perfectly functional.

## Prerequisites

- Ubuntu installed
- Storage drive(s) available

---

## Option A: Single Drive Setup

Use this if you have one drive (SSD or HDD) for everything.

### Step 1: Create the Data Directory

```bash
sudo mkdir -p /data
sudo chown $USER:$USER /data
```

### Step 2: Create Media Directories

```bash
mkdir -p /data/media/{movies,tv,homevideo}
```

This creates:
```
/data/media/
├── movies/      # Feature films
├── tv/          # TV series
└── homevideo/   # Personal videos (optional)
```

### Step 3: Create Download Directories

```bash
mkdir -p ~/downloads/{incomplete,complete}
```

This creates:
```
~/downloads/
├── incomplete/    # In-progress downloads
└── complete/      # Finished downloads (awaiting import)
```

### Step 4: Create Mediaserver Config Directory

```bash
mkdir -p ~/mediaserver/config
```

### Step 5: Verify Everything

```bash
ls -la /data/media/
ls -la ~/downloads/
```

You should see the directories you created.

**Done!** Skip to [Application Paths](#application-paths) below.

---

## Option B: Two-Drive Setup

Use this if you have an SSD (for OS and downloads) and a separate HDD (for media storage).

**Why two drives?** Torrent downloads involve lots of random I/O that SSDs handle well. Media files are large and accessed sequentially, so HDDs work great and offer more capacity per dollar. The *arr applications automatically move completed downloads from SSD to HDD.

### Step 1: Find Your Second Drive

```bash
lsblk
```

Look for your second drive. It will be something like `sdb` or `sdc` (not `sda` which is usually your boot drive).

Example output:
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 476.9G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
└─sda2   8:2    0 476.4G  0 part /
sdb      8:16   0   3.6T  0 disk
└─sdb1   8:17   0   3.6T  0 part
```

In this example, `sdb1` is the second drive partition.

### Step 2: Check if Drive Has a Filesystem

```bash
sudo blkid /dev/sdb1
```

If it shows a filesystem type (like `ext4` or `ntfs`), the drive is already formatted.

### Step 3: Format the Drive (If Needed)

> **Warning:** This erases all data on the drive!

If the drive is new or you want to start fresh:

```bash
sudo mkfs.ext4 -L mediastore /dev/sdb1
```

### Step 4: Create Mount Point

```bash
sudo mkdir -p /data
```

### Step 5: Get the UUID

```bash
sudo blkid /dev/sdb1 | grep -oP 'UUID="\K[^"]+'
```

Copy this UUID for the next step.

### Step 6: Add to fstab for Automatic Mounting

Edit fstab:

```bash
sudo nano /etc/fstab
```

Add this line at the end (replacing `your-uuid-here` with the actual UUID):

```
UUID=your-uuid-here /data ext4 defaults 0 2
```

Save and exit (Ctrl+X, then Y, then Enter).

### Step 7: Mount the Drive

```bash
sudo mount -a
```

Verify it mounted:

```bash
df -h /data
```

You should see your drive mounted at `/data`.

### Step 8: Create Media Directories

```bash
sudo mkdir -p /data/media/{movies,tv,homevideo}
sudo chown -R $USER:$USER /data/media
chmod -R 755 /data/media
```

### Step 9: Create Download Directories (on SSD)

```bash
mkdir -p ~/downloads/{incomplete,complete}
```

Downloads go in your home directory (on the SSD) and get moved to `/data/media` (on the HDD) after completion.

### Step 10: Create Mediaserver Config Directory

```bash
mkdir -p ~/mediaserver/config
```

### Step 11: Verify Everything

```bash
ls -la /data/media/
ls -la ~/downloads/
df -h /data
```

---

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

## Directory Summary

| Directory | Purpose |
|-----------|---------|
| `/data/media/movies` | Movie library |
| `/data/media/tv` | TV show library |
| `/data/media/homevideo` | Personal videos |
| `~/downloads/complete` | Finished downloads |
| `~/downloads/incomplete` | In-progress downloads |
| `~/mediaserver/config` | Service configurations |

## Troubleshooting

### Second Drive Not Showing Up

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
