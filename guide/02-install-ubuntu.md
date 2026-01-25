# Chapter 2: Install Ubuntu

This chapter covers installing the latest Ubuntu Server LTS on your hardware.

## Overview

Ubuntu Server is the foundation of your media server. We use the **Server** edition (not Desktop) because:
- Smaller footprint (no GUI overhead)
- Better suited for headless operation
- More stable for 24/7 operation

> **Desktop vs Server:** Ubuntu comes in two main editions. **Desktop** includes a graphical interface (GUI) and is designed for everyday computer use. **Server** is command-line only and designed for running services 24/7. We use Server because there's no point running a GUI that consumes RAM and CPU when you'll be managing everything remotely via SSH anyway.

## Prerequisites

- Bootable USB drive with the latest Ubuntu Server LTS ([download here](https://ubuntu.com/download/server))
- Monitor and keyboard connected to server
- Ethernet cable connected to router
- Internet connection

## Installation Steps

### 1. Boot from USB

1. Insert the USB drive
2. Power on the computer
3. Press the boot menu key (usually F12, F2, or ESC)
4. Select the USB drive

### 2. Start Installation

1. Select **Try or Install Ubuntu Server**
2. Choose your language (English recommended)
3. Select your keyboard layout

### 3. Choose Installation Type

Select **Ubuntu Server** (not minimized).

### 4. Network Configuration

Ubuntu should automatically detect your ethernet connection via DHCP.

If you see an IP address (like `192.168.1.x`), networking is working. Continue to the next step.

> **Note:** We'll configure a static IP later. DHCP is fine for installation.

### 5. Proxy Configuration

Leave blank unless your network requires a proxy.

### 6. Mirror Configuration

Keep the default Ubuntu mirror. It will auto-select one near you.

### 7. Storage Configuration

This is where you configure your SSD. **Read carefully.**

#### Simple Setup (Single SSD)

If you have one SSD for the OS:

1. Select **Use an entire disk**
2. Choose your SSD
3. Confirm the storage layout

#### Advanced Setup (SSD + HDD)

If you have both SSD and HDD installed:

1. Select **Custom storage layout**
2. Configure the SSD for the root partition:
   - Select the SSD
   - Add GPT partition table
   - Create partition: mount point `/`, format `ext4`, use entire SSD
3. **Do not** configure the HDD during installation - we'll mount it later

> **Tip:** It's easier to mount the HDD after Ubuntu is installed. Focus on getting the SSD configured correctly.

### 8. Profile Setup

| Field | Recommendation |
|-------|----------------|
| Your name | Your actual name |
| Server name | Short hostname (e.g., `mediaserver`) |
| Username | Lowercase, no spaces (e.g., `alex`, `admin`, `media`) |
| Password | Strong password - you'll use this for sudo |

> **Important:** Remember your username! It's used in paths throughout this guide.

### 9. SSH Setup

**Enable OpenSSH server** - Check this option!

You can optionally import SSH keys from GitHub:
- Select **Import SSH identity**
- Choose **from GitHub**
- Enter your GitHub username

If you don't have SSH keys yet, skip this - we'll set them up in [Chapter 4](04-ssh-security.md).

### 10. Featured Server Snaps

**Do not select any snaps.** We'll install Docker manually from the official repository.

Specifically:
- **Do not install docker** from snaps (it has permission issues)
- Skip all other options

### 11. Installation

The installer will:
1. Copy files to your SSD
2. Configure the system
3. Set up the bootloader

This takes 5-15 minutes depending on your hardware.

### 12. Reboot

1. Remove the USB drive when prompted
2. Let the system reboot
3. Wait for the login prompt

## First Login

At the console, log in with your username and password.

You should see a command prompt:
```
your-username@mediaserver:~$
```

## Post-Installation Tasks

### 1. Update the System

```bash
sudo apt update && sudo apt upgrade -y
```

This may take several minutes. Reboot if prompted:
```bash
sudo reboot
```

### 2. Find Your IP Address

```bash
ip addr show
```

Look for the `inet` line under your ethernet interface (usually `eth0`, `enp0s3`, or similar):
```
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic enp0s3
```

In this example, the IP is `192.168.1.100`.

**Write down this IP address** - you'll need it for SSH access.

### 3. Test SSH Access

From another computer on your network, test SSH:

```bash
ssh your-username@<server-ip>
```

Replace `your-username` and `<server-ip>` with your actual values.

If this works, you can disconnect the monitor and keyboard from the server and continue via SSH.

## Verification

Verify your installation:

```bash
# Check Ubuntu version
cat /etc/os-release | grep VERSION
```
Expected output includes: `VERSION="XX.04 LTS"` (where XX is the version number, e.g., 24, 26)

```bash
# Check available disk space
df -h /
```
You should see your SSD with available space.

```bash
# Check memory
free -h
```
Shows your RAM allocation.

```bash
# Check CPU
lscpu | grep "Model name"
```
Shows your CPU model.

## Troubleshooting

### Can't boot from USB

- Check BIOS boot order
- Try a different USB port
- Recreate the USB drive

### No network connection

- Check ethernet cable
- Verify router DHCP is enabled
- Try `sudo dhclient` to request an IP

### SSH connection refused

- Verify SSH is installed: `sudo apt install openssh-server`
- Check SSH is running: `sudo systemctl status ssh`
- Check firewall: `sudo ufw status` (should be inactive by default)

### "Permission denied" when using sudo

- Verify your password is correct
- Ensure your user was created as an administrator during installation

## Next Steps

You now have a basic Ubuntu Server installation. In the next chapters, we'll:

1. Install Docker
2. Secure SSH access
3. Set up storage
4. Install Plex and the *arr stack

From this point on, all work can be done via SSH from your main computer.

---

**Previous:** [Chapter 1: Hardware and Planning](01-hardware-and-planning.md)

**Next:** [Chapter 3: Install Docker](03-install-docker.md)
