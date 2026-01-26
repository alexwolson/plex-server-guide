# Chapter 6: Install Plex Media Server

[Plex](https://www.plex.tv/) is your media server - it organizes your library and streams content to devices anywhere in the world.

## Overview

We install Plex **natively** (not in Docker) for better hardware transcoding performance and simpler setup.

**Why native instead of Docker?**

- Direct access to Intel Quick Sync Video (QSV) for hardware transcoding
- No container overhead for high-bandwidth streaming
- Simpler GPU device passthrough
- Plex's built-in update mechanism works seamlessly

## Prerequisites

- Ubuntu Server LTS with storage configured ([Chapter 5](05-storage-setup.md))
- Media directories created at `/data/media/`
- Intel CPU for hardware transcoding (recommended)

## Installation Steps

### 1. Add Plex GPG Key

```bash
curl -s https://downloads.plex.tv/plex-keys/PlexSign.key | sudo gpg --dearmor -o /usr/share/keyrings/plex.gpg
```

### 2. Add Plex Repository

```bash
echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
```

### 3. Install Plex

```bash
sudo apt update
sudo apt install -y plexmediaserver
```

### 4. Enable and Start Plex

```bash
sudo systemctl enable --now plexmediaserver
```

## Verification

### Check Service Status

```bash
systemctl is-active plexmediaserver
```
Expected output: `active`

### Check Web Interface Responds

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:32400/web/index.html
```
Expected output: `200`

## Initial Setup

### 1. Access the Web Interface

Open a browser and go to:
```
http://<server-ip>:32400/web
```

Replace `<server-ip>` with your server's IP address.

### 2. Sign In to Plex

- Click **Sign In**
- Create a Plex account or sign in with existing account
- You'll be redirected back to your server

### 3. Name Your Server

- Choose a name for your server (e.g., "Home Media Server")
- This name appears in Plex apps

### 4. Add Libraries

Click **Add Library** and create these:

#### Movies Library

1. Select **Movies** as the type
2. Click **Add Folder**
3. Enter path: `/data/media/movies`
4. Click **Add Library**

#### TV Shows Library

1. Select **TV Shows** as the type
2. Click **Add Folder**
3. Enter path: `/data/media/tv`
4. Click **Add Library**

#### Home Videos (Optional)

1. Select **Home Videos** as the type
2. Click **Add Folder**
3. Enter path: `/data/media/homevideo`
4. Click **Add Library**

### 5. Complete Setup

- Skip the other setup options for now
- Click **Done**

You can always add more libraries later from **Settings > Libraries**.

## Hardware Transcoding

Transcoding converts video from one format to another on-the-fly. When a device can't play the original format (e.g., a browser that doesn't support HEVC), Plex converts it to something compatible.

**Do you actually need transcoding?**

Strictly speaking, no. You can disable transcoding entirely in Plex settings, and it will simply refuse to play content when the format isn't compatible with the requesting device. However, most people want a "play anything, anywhere" experience—streaming to phones, tablets, browsers, and smart TVs without worrying about codec compatibility. You may also want to adjust streaming quality on the fly (useful when bandwidth is limited). Both of these really benefit from hardware transcoding.

Hardware transcoding uses your Intel CPU's Quick Sync Video (QSV) to convert video formats efficiently, offloading the work from your main CPU cores. Without hardware acceleration, transcoding is CPU-intensive and a modest server might only handle one or two simultaneous transcodes. With QSV, the same server can handle many more.

Hardware transcoding requires a [Plex Pass](../appendices/F-plex-pass-features.md) subscription.

### Verify Intel QSV is Available

```bash
ls -la /dev/dri/
```

You should see `card0` and `renderD128`:
```
drwxr-xr-x  3 root root         100 Jan  1 00:00 .
drwxr-xr-x 20 root root        4600 Jan  1 00:00 ..
drwxr-xr-x  2 root root          80 Jan  1 00:00 by-path
crw-rw----  1 root video  226,   0 Jan  1 00:00 card0
crw-rw----  1 root render 226, 128 Jan  1 00:00 renderD128
```

### Add Plex User to Required Groups

```bash
sudo usermod -aG render plex
sudo usermod -aG video plex
sudo systemctl restart plexmediaserver
```

### Enable Hardware Transcoding in Plex

1. Open Plex Web at `http://<server-ip>:32400/web`
2. Go to **Settings** (wrench icon)
3. Click **Transcoder** under Settings
4. Enable **Use hardware acceleration when available**
5. Enable **Use hardware-accelerated video encoding**
6. Save changes

### Verify Hardware Transcoding Works

1. Play a video that requires transcoding (different format than original)
2. While playing, go to **Settings > Dashboard**
3. Look at the Now Playing section
4. If you see "(hw)" next to the transcode, hardware transcoding is working

## File Locations

| Item | Path |
|------|------|
| Data directory | `/var/lib/plexmediaserver/` |
| Library/metadata | `/var/lib/plexmediaserver/Library/` |
| Config | `/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/` |
| Logs | `/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Logs/` |
| Service user | `plex` |
| Default port | `32400` |

## Adding Content

For now, your libraries are empty. Content will be added through:

1. **Manual upload** - Copy files to `/data/media/movies` or `/data/media/tv`
2. **Sonarr/Radarr** - Automatic downloads (configured in later chapters)

After adding content, you may need to refresh the library:
- Click the **...** menu on a library
- Select **Scan Library Files**

## Remote Access (Preview)

Plex has built-in remote access that works through Plex's relay servers. We'll configure direct remote access in [Chapter 18](18-plex-remote-access.md).

For now, Plex should be accessible on your local network.

## Troubleshooting

### Web Interface Not Loading

1. Check Plex is running:
   ```bash
   sudo systemctl status plexmediaserver
   ```

2. Check logs for errors:
   ```bash
   sudo tail -f /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Logs/Plex\ Media\ Server.log
   ```

### Permission Issues with Media

If Plex can't access your media files:

```bash
# Check Plex can read the media directory
sudo -u plex ls /data/media/movies

# If permission denied, fix permissions
sudo chmod -R 755 /data/media
```

### Hardware Transcoding Not Working

1. Verify the `plex` user is in the render group:
   ```bash
   groups plex
   ```

2. Check if the render device exists:
   ```bash
   ls -la /dev/dri/renderD128
   ```

3. Restart Plex after group changes:
   ```bash
   sudo systemctl restart plexmediaserver
   ```

### Server Not Appearing in Plex App

1. Make sure you're signed in with the same Plex account
2. Check Plex can reach the internet:
   ```bash
   curl -I https://plex.tv
   ```
3. Restart the Plex service:
   ```bash
   sudo systemctl restart plexmediaserver
   ```

## Next Steps

Plex is installed and ready for content. Next, we'll deploy the Docker Compose stack with all the automation services.

---

**Previous:** [Chapter 5: Storage Setup](05-storage-setup.md)

**Next:** [Chapter 7: Docker Compose Stack](07-docker-compose-stack.md)
