# Chapter 3: Install Docker

Docker is a containerization platform that lets you run applications in isolated environments. Most of our media server services run in Docker containers.

## Overview

We'll install Docker Engine from the official Docker repository - **not** the Ubuntu snap package.

**Why not the snap version?** The snap-packaged Docker has AppArmor restrictions that interfere with VPN container networking (specifically the nordlynx container we'll use for VPN).

## Prerequisites

- Ubuntu Server LTS installed ([Chapter 2](02-install-ubuntu.md))
- SSH access to your server
- sudo privileges

## What Gets Installed

- **Docker Engine** - The core container runtime
- **Docker CLI** - Command-line interface
- **Docker Compose** - Tool for defining multi-container applications
- **containerd** - Container runtime

## Installation Steps

### 1. Install Prerequisites

```bash
sudo apt update && sudo apt install -y ca-certificates curl
```

### 2. Add Docker's Official GPG Key

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

**What this does:**
- **Line 1:** Creates the `/etc/apt/keyrings` directory with permissions `0755` (readable by everyone, writable only by root). This is where Ubuntu stores cryptographic keys for verifying packages.
- **Line 2:** Downloads Docker's GPG public key and saves it as `docker.asc`. This key is used to verify that Docker packages haven't been tampered with.
- **Line 3:** Makes the key readable by all users (required for apt to use it).

**Why GPG keys matter:** When you install software, you want to be sure it actually came from Docker and wasn't modified by an attacker. GPG signatures prove authenticity - if a package doesn't match Docker's signature, apt will refuse to install it.

### 3. Add Docker Repository

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**What this does:** Adds Docker's package repository to your system so apt knows where to download Docker from. Let's break down this complex command:

- `dpkg --print-architecture` - Detects your CPU architecture (usually `amd64` for Intel/AMD 64-bit)
- `signed-by=/etc/apt/keyrings/docker.asc` - Tells apt to verify packages using the GPG key we just downloaded
- `. /etc/os-release && echo "$VERSION_CODENAME"` - Detects your Ubuntu version codename (e.g., `noble` for 24.04, `jammy` for 22.04)
- `sudo tee /etc/apt/sources.list.d/docker.list` - Writes the repository configuration to a file that apt will read
- `> /dev/null` - Suppresses the output (tee normally prints what it writes)

**Why not Ubuntu's built-in Docker?** Ubuntu includes Docker in its default repositories, but it's often outdated. Docker's official repository always has the latest stable version.

### 4. Install Docker Packages

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**What this does:**
- Installs five packages:
  - **docker-ce** - Docker Community Edition, the main Docker engine that runs containers
  - **docker-ce-cli** - The `docker` command-line tool you'll use to manage containers
  - **containerd.io** - The underlying container runtime that Docker uses
  - **docker-buildx-plugin** - Extended build capabilities (for building container images)
  - **docker-compose-plugin** - The `docker compose` command for managing multi-container applications (this is what we'll use to run our media server stack)

### 5. Add Your User to the Docker Group

```bash
sudo usermod -aG docker $USER
```

**What this does:** Adds your user account to the `docker` group.

- `usermod` - Modifies a user account
- `-aG docker` - **A**ppends the user to the `docker` **G**roup (without removing them from other groups)
- `$USER` - A variable that contains your username

**Why this matters:** By default, only root can communicate with the Docker daemon. Adding yourself to the `docker` group lets you run Docker commands without typing `sudo` every time. This is a convenience feature, but it's also important for running tools that expect Docker access.

> **Important:** You need to log out and back in for this to take effect. Either:
> - Close your SSH session and reconnect, or
> - Run `newgrp docker` to activate the group in the current session

## Verification

After logging back in, verify the installation:

### Check Docker Version

```bash
docker --version
```
Expected output: `Docker version 27.x.x` or similar

### Check Docker Compose Version

```bash
docker compose version
```
Expected output: `Docker Compose version v2.x.x` or similar

### Check Docker Service Status

```bash
systemctl is-active docker
```
Expected output: `active`

### Test Docker Works

Run a test container:

```bash
docker run hello-world
```

Expected output should include:
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### Verify No Sudo Required

Try running a Docker command without sudo:

```bash
docker ps
```

If you get a permission error, make sure you logged out and back in after adding yourself to the docker group.

## Understanding Docker Basics

Here are some commands you'll use throughout this guide:

| Command | Purpose |
|---------|---------|
| `docker ps` | List running containers |
| `docker ps -a` | List all containers (including stopped) |
| `docker logs <container>` | View container logs |
| `docker exec -it <container> bash` | Open a shell inside a container |
| `docker compose up -d` | Start services defined in docker-compose.yml |
| `docker compose down` | Stop and remove containers |
| `docker compose pull` | Download latest images |

## Troubleshooting

### "Permission denied" when running Docker

You need to log out and back in after adding yourself to the docker group:

```bash
# Check if you're in the docker group
groups | grep docker
```

If docker isn't listed, run `sudo usermod -aG docker $USER` again and log out/in.

### Docker service won't start

Check for errors:

```bash
sudo systemctl status docker
sudo journalctl -xeu docker
```

### "Cannot connect to Docker daemon"

The Docker service might not be running:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Snap Docker was previously installed

If you previously installed Docker via snap, remove it first:

```bash
sudo snap remove docker
```

Then follow the installation steps above.

## Docker Storage Location

By default, Docker stores its data in `/var/lib/docker`. This includes:
- Downloaded images
- Container filesystems
- Volumes

This is fine for most setups. If you need to move Docker storage to a different drive, that's an advanced configuration not covered in this guide.

## Next Steps

Docker is installed and ready. In the next chapter, we'll secure SSH access to prevent unauthorized access to your server.

---

**Previous:** [Chapter 2: Install Ubuntu](02-install-ubuntu.md)

**Next:** [Chapter 4: SSH Security](04-ssh-security.md)
