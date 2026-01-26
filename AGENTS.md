# AGENTS.md - LLM Agent Implementation Guide

## Introduction

This document provides comprehensive instructions for LLM agents to implement the Home Media Server Guide on behalf of users. This guide walks through building a complete home media server with automated content management, secure remote access, and VPN-protected downloads.

**Important Context:**
- This guide was largely written by Claude Code, drawing from messy notes, config files, and outputs from the author's own server installation
- The guide is currently under manual review - the author has read through everything once and it is broadly correct, but full verification is still in progress
- The guide consists of 23 chapters (0-22) plus appendices, organized into four main phases

**What You'll Be Building:**
- **Plex Media Server** - Native installation for hardware transcoding
- **Sonarr & Radarr** - Automated TV show and movie management
- **Prowlarr** - Centralized indexer management
- **qBittorrent + NordVPN** - VPN-protected torrent downloads
- **Caddy** - Optional HTTPS reverse proxy with automatic SSL
- **Jellyseerr** - Optional request management interface
- **Bazarr** - Optional automatic subtitle downloads

## Project Structure

### Guide Chapters (`guide/`)

The guide is organized into four parts:

**Part 1: Foundation (Chapters 0-5)**
- `00-introduction.md` - Overview and skill requirements
- `01-hardware-and-planning.md` - Hardware requirements and planning checklist
- `02-install-ubuntu.md` - Ubuntu Server LTS installation
- `03-install-docker.md` - Docker Engine installation
- `04-ssh-security.md` - SSH hardening with fail2ban
- `05-storage-setup.md` - Directory structure and storage configuration

**Part 2: Core Services (Chapters 6-13)**
- `06-install-plex.md` - Native Plex Media Server installation
- `07-docker-compose-stack.md` - Deploy all containerized services
- `08-configure-qbittorrent.md` - Torrent client configuration
- `09-configure-prowlarr.md` - Indexer management setup
- `10-configure-sonarr.md` - TV show automation configuration
- `11-configure-radarr.md` - Movie automation configuration
- `12-configure-bazarr.md` - Subtitle automation (optional)
- `13-configure-jellyseerr.md` - Request management (optional)

**Part 3: Remote Access (Chapters 14-18) - Optional**
- `14-domain-and-dns.md` - Domain purchase and DNS configuration
- `15-router-configuration.md` - Port forwarding and static IP
- `16-caddy-reverse-proxy.md` - HTTPS reverse proxy setup
- `17-ddns-updater.md` - Dynamic DNS updates
- `18-plex-remote-access.md` - Enable Plex remote streaming

**Part 4: Security and Extras (Chapters 19-21)**
- `19-vpn-killswitch.md` - Host-level VPN enforcement (optional)
- `20-verification-checklist.md` - Complete system verification
- `21-maintenance.md` - Updates, backups, and troubleshooting

### Appendices (`appendices/`)

Reference materials:
- `A-nordvpn-wireguard-key.md` - How to obtain NordVPN WireGuard key
- `B-indexer-tracker-guide.md` - Understanding indexers and trackers
- `C-troubleshooting.md` - Common problems and solutions
- `D-service-ports-reference.md` - Port reference table
- `E-file-paths-reference.md` - Directory structure reference

### Configuration Files (`configs/`)

Ready-to-use templates:
- `docker-compose.yml` - Full Docker Compose stack
- `example.env` - Environment variables template
- `Caddyfile.example` - Reverse proxy configuration
- `ddns-config.json.example` - DDNS updater configuration
- `scripts/` - Helper scripts (kill-switch, SSH hardening)

### Documentation Files

- `README.md` - Main entry point with overview and quick reference
- `ARCHITECTURE.md` - Detailed system architecture and component explanations

## Implementation Strategy

### Sequential Execution

**Always follow chapters 0-22 in order.** Each chapter builds on previous ones. Do not skip ahead or jump between chapters.

### Prerequisites Checking

Before starting each chapter:
1. Verify all prerequisites from the chapter's "Prerequisites" section are met
2. Check that previous chapters have been completed successfully
3. Verify any required services are running (use `systemctl status` for native services, `docker ps` for containers)
4. Confirm required directories and files exist

### User Confirmation Protocol

**Get explicit user approval before:**
- Installing new software packages
- Modifying system configuration files
- Creating or modifying firewall rules
- Making changes to network configuration
- Performing any destructive operations

**Always confirm:**
- User-specific values (usernames, paths, IP addresses)
- Optional feature decisions (domain setup, Caddy, optional services)
- Before proceeding with steps that cannot be easily undone

### Incremental Verification

After each major component installation:
1. Verify the service is running
2. Test basic functionality
3. Check logs for errors
4. Confirm connectivity (if applicable)
5. Report status to the user

### Configuration Customization

**Always adapt configurations to the user's environment:**
- Replace placeholders with actual values
- Use user's actual username, paths, and IP addresses
- Set correct timezone
- Use user's actual PUID/PGID values
- Apply user's domain name (if applicable)

## Step-by-Step Execution Guidelines

### Part 1: Foundation (Chapters 0-5)

#### Chapter 0: Introduction
- **Action:** Read and present overview to user
- **User Input:** Confirm they understand requirements and have necessary accounts
- **Verification:** None required (informational only)

#### Chapter 1: Hardware and Planning
- **Action:** Guide user through hardware verification and planning checklist
- **User Input Required:**
  - Server username
  - HDD mount point preference
  - Domain name decision (optional)
  - Static IP address (if applicable)
- **Verification:** Confirm user has completed planning checklist
- **Note:** User must have hardware ready and accounts created (NordVPN, Plex)

#### Chapter 2: Install Ubuntu
- **Action:** Guide user through Ubuntu Server installation
- **User Input:** User must perform installation manually (physical access required)
- **Verification:** 
  - User confirms successful installation
  - SSH access works
  - User can log in
- **Note:** This step typically requires user to be physically present at the server

#### Chapter 3: Install Docker
- **Action:** Execute Docker installation commands
- **Prerequisites:** Ubuntu installed, user logged in via SSH
- **User Confirmation:** Get approval before installing Docker
- **Verification:**
  ```bash
  docker --version
  sudo systemctl status docker
  ```
- **Commands:** Follow exact commands from guide chapter

#### Chapter 4: SSH Security
- **Action:** Configure SSH hardening and fail2ban
- **Prerequisites:** Docker installed, SSH access working
- **User Confirmation:** Critical - warn user about potential lockout risk
- **Verification:**
  ```bash
  sudo systemctl status sshd
  sudo systemctl status fail2ban
  ```
- **Important:** Test SSH connection before closing session after changes

#### Chapter 5: Storage Setup
- **Action:** Create directory structure and configure storage
- **Prerequisites:** Docker installed
- **User Input Required:**
  - Username (for paths)
  - HDD mount point
  - Confirmation of directory structure
- **Verification:**
  ```bash
  ls -la /data/media
  ls -la ~/downloads
  ls -la ~/mediaserver/config
  ```
- **Commands:** Create directories with correct permissions

### Part 2: Core Services (Chapters 6-13)

#### Chapter 6: Install Plex
- **Action:** Install Plex Media Server natively (not Docker)
- **Prerequisites:** Storage configured, media directories exist
- **User Input Required:**
  - Plex account credentials (user must create account if needed)
  - Server name preference
- **User Confirmation:** Get approval before installing Plex
- **Verification:**
  ```bash
  systemctl is-active plexmediaserver
  curl -s -o /dev/null -w "%{http_code}" http://localhost:32400/web/index.html
  ```
- **Note:** User must complete initial Plex setup via web interface

#### Chapter 7: Docker Compose Stack
- **Action:** Deploy all containerized services
- **Prerequisites:** Plex installed, storage configured
- **User Input Required:**
  - NordVPN WireGuard private key (see Appendix A)
  - Username (for paths)
  - PUID/PGID (run `id` command)
  - Timezone
- **User Confirmation:** Get approval before deploying stack
- **Steps:**
  1. Create directory structure
  2. Guide user to obtain NordVPN WireGuard key (Appendix A)
  3. Create `.env` file from template, customize with user values
  4. Create `docker-compose.yml` from template, customize paths
  5. Start services: `docker compose up -d`
- **Verification:**
  ```bash
  docker compose ps
  docker logs nordlynx --tail 20
  docker exec nordlynx curl -s https://ifconfig.io
  ```
- **Critical:** Verify VPN is working before proceeding

#### Chapter 8: Configure qBittorrent
- **Action:** Configure torrent client via web interface
- **Prerequisites:** Docker Compose stack running, VPN verified
- **User Input:** User must access web interface via SSH tunnel
- **Steps:**
  1. Guide user to create SSH tunnel: `ssh -L 8080:localhost:8080 user@server-ip`
  2. Help user find temporary password from logs
  3. Guide user through web interface configuration
- **Verification:** User confirms qBittorrent is accessible and configured
- **Note:** This requires user interaction with web interface

#### Chapter 9: Configure Prowlarr
- **Action:** Configure indexer management
- **Prerequisites:** Docker Compose stack running
- **User Input:** User must add indexers via web interface
- **Steps:**
  1. Guide user to access Prowlarr web interface
  2. Help user add indexers (user must have indexer accounts)
  3. Configure sync to Sonarr/Radarr
- **Verification:** User confirms indexers are added and syncing
- **Note:** User must have indexer accounts (not provided in guide)

#### Chapter 10: Configure Sonarr
- **Action:** Configure TV show automation
- **Prerequisites:** Prowlarr configured, qBittorrent configured
- **User Input:** User must configure via web interface
- **Steps:**
  1. Guide user to access Sonarr web interface
  2. Configure download client (qBittorrent)
  3. Configure indexers (from Prowlarr)
  4. Set root folder for TV shows
  5. Configure quality profiles
- **Verification:** User confirms Sonarr can search and download
- **Note:** Extensive web interface configuration required

#### Chapter 11: Configure Radarr
- **Action:** Configure movie automation
- **Prerequisites:** Prowlarr configured, qBittorrent configured
- **User Input:** User must configure via web interface
- **Steps:**
  1. Guide user to access Radarr web interface
  2. Configure download client (qBittorrent)
  3. Configure indexers (from Prowlarr)
  4. Set root folder for movies
  5. Configure quality profiles
- **Verification:** User confirms Radarr can search and download
- **Note:** Similar to Sonarr, extensive web interface configuration

#### Chapter 12: Configure Bazarr (Optional)
- **Action:** Configure subtitle automation
- **Prerequisites:** Sonarr and Radarr configured
- **User Input:** User decision on whether to use Bazarr
- **Steps:** If user wants Bazarr, guide through web interface configuration
- **Verification:** User confirms subtitles are downloading
- **Note:** Optional service - ask user if they want it

#### Chapter 13: Configure Jellyseerr (Optional)
- **Action:** Configure request management interface
- **Prerequisites:** Plex, Sonarr, Radarr configured
- **User Input:** User decision on whether to use Jellyseerr
- **Steps:** If user wants Jellyseerr, guide through web interface configuration
- **Verification:** User confirms Jellyseerr is working
- **Note:** Optional service - ask user if they want it

### Part 3: Remote Access (Chapters 14-18) - Optional

#### Chapter 14: Domain and DNS (Optional)
- **Action:** Guide user through domain purchase and DNS setup
- **User Decision:** Ask if user wants custom domain
- **User Input:** User must purchase domain and configure DNS
- **Steps:** Guide user through DNS provider interface
- **Verification:** DNS records propagate correctly
- **Note:** Plex works without domain - this is for pretty URLs

#### Chapter 15: Router Configuration
- **Action:** Guide user through router port forwarding
- **User Input:** User must access router admin interface
- **Steps:** Provide instructions for common router brands
- **Verification:** User confirms ports are forwarded
- **Note:** User must do this manually - agent cannot access router

#### Chapter 16: Caddy Reverse Proxy (Optional)
- **Action:** Configure Caddy for HTTPS
- **Prerequisites:** Domain configured (if using), router configured
- **User Decision:** Ask if user wants Caddy (only needed for external access to services other than Plex)
- **User Input:** Domain name (if using)
- **Steps:**
  1. Create Caddyfile from template
  2. Customize with user's domain
  3. Update docker-compose.yml if needed
  4. Restart Caddy container
- **Verification:**
  ```bash
  docker logs caddy --tail 20
  curl -I https://user-domain.com
  ```
- **Note:** Optional - Plex has built-in remote access

#### Chapter 17: DDNS Updater (Optional)
- **Action:** Configure dynamic DNS updates
- **Prerequisites:** Domain configured, Caddy configured (if using)
- **User Decision:** Ask if user has dynamic IP and needs DDNS
- **User Input:** DNS provider credentials
- **Steps:** Configure DDNS updater container
- **Verification:** DNS updates when IP changes
- **Note:** Only needed if IP address changes frequently

#### Chapter 18: Plex Remote Access
- **Action:** Enable Plex remote access
- **Prerequisites:** Plex installed, router configured (if needed)
- **User Input:** User must configure via Plex web interface
- **Steps:** Guide user through Plex remote access settings
- **Verification:** User confirms remote access works
- **Note:** Plex handles this automatically in most cases

### Part 4: Security and Extras (Chapters 19-22)

#### Chapter 19: VPN Kill-Switch (Optional)
- **Action:** Configure host-level VPN enforcement
- **Prerequisites:** Docker Compose stack running, VPN working
- **User Decision:** Ask if user wants additional VPN protection
- **Steps:** Install and configure kill-switch scripts
- **Verification:** VPN kill-switch prevents leaks
- **Note:** Optional additional security layer

#### Chapter 20: Verification Checklist
- **Action:** Run comprehensive system verification
- **Prerequisites:** All services installed and configured
- **Steps:**
  1. Check all services are running
  2. Verify VPN connectivity
  3. Test service web interfaces
  4. Verify inter-service connectivity
  5. Test download and import workflow
  6. Verify Plex library scanning
- **Verification:** Complete checklist from guide chapter
- **Output:** Provide verification report to user

#### Chapter 21: Maintenance
- **Action:** Set up maintenance procedures
- **Prerequisites:** System fully configured
- **Steps:**
  1. Document update procedures
  2. Set up backup recommendations
  3. Provide troubleshooting resources
- **Verification:** User understands maintenance procedures
- **Note:** Informational - sets up ongoing maintenance

## User Interaction Protocol

### Required User Input Points

**Before Starting:**
- Server username
- Hardware specifications
- Network information (IP addresses, subnet)
- Account status (NordVPN, Plex)
- Domain decision (optional)

**During Foundation Phase:**
- Ubuntu installation confirmation (user does manually)
- SSH access confirmation
- Storage mount points
- Directory structure confirmation

**During Core Services Phase:**
- NordVPN WireGuard key (guide user to Appendix A)
- Plex account credentials
- PUID/PGID values
- Timezone
- Web interface configurations (user must do via browser)

**During Remote Access Phase:**
- Domain purchase decision
- Domain name (if applicable)
- Router configuration (user does manually)
- DNS provider credentials (if using DDNS)

**During Security & Extras:**
- Optional feature decisions
- Additional configuration preferences

### Confirmation Points

**Always get explicit approval before:**
- Installing software packages
- Modifying system configuration files
- Changing firewall rules
- Modifying network settings
- Creating or modifying service configurations
- Starting/stopping services

**Use clear language:**
- "I need your approval to install Docker. This will modify system packages. Proceed?"
- "I'm about to modify SSH configuration. This could affect your access. Have you tested the current SSH connection? Proceed?"
- "I need to create the Docker Compose stack. This will start multiple containers. Proceed?"

### Progress Updates

**Provide regular status updates:**
- After each chapter completion
- When waiting for user input
- When verification passes or fails
- When errors occur

**Update format:**
```
✓ Chapter 3 Complete: Docker installed and verified
→ Next: Chapter 4 - SSH Security
⏸ Waiting for: Your approval to proceed with SSH hardening
```

### Error Reporting

**When errors occur:**
1. Clearly explain what went wrong
2. Show relevant error messages/logs
3. Reference troubleshooting appendix if applicable
4. Suggest specific fixes
5. Ask user if they want to proceed with fix or need help

**Example:**
```
❌ Error: Docker container 'nordlynx' failed to start

Log output:
[Error] Failed to connect to NordVPN: Invalid WireGuard key

Possible causes:
1. WireGuard key in .env file is incorrect
2. Key format issue (extra spaces, newlines)

Suggested fix: Verify the WIREGUARD_PRIVATE_KEY in ~/mediaserver/.env
matches the key from Appendix A instructions.

Would you like me to help you verify the key, or do you want to check it yourself?
```

### Decision Points

**Clearly present optional features:**
- "Caddy reverse proxy is optional. It provides HTTPS URLs for services other than Plex. Plex has built-in remote access. Do you want to set up Caddy? (yes/no)"
- "Bazarr automatically downloads subtitles. Do you want to configure it? (yes/no)"
- "A domain name gives you pretty URLs like https://media.example.com. Plex works without it. Do you want to set up a domain? (yes/no)"

## Verification and Testing

### Service Status Checks

**Native Services (systemd):**
```bash
systemctl is-active servicename
systemctl status servicename
```

**Docker Services:**
```bash
docker compose ps
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Port Accessibility Tests

**Local ports:**
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:PORT
netstat -tlnp | grep :PORT
```

**Remote ports (if applicable):**
```bash
curl -s -o /dev/null -w "%{http_code}" http://server-ip:PORT
```

### Web Interface Verification

**Test each service web interface:**
- Plex: `http://server-ip:32400/web`
- Sonarr: `http://server-ip:8989`
- Radarr: `http://server-ip:7878`
- Prowlarr: `http://server-ip:9696`
- qBittorrent: Via SSH tunnel to `http://localhost:8080`

**Expected:** HTTP 200 response or successful page load

### Inter-Service Communication Tests

**Docker network connectivity:**
```bash
docker exec sonarr ping -c 2 radarr
docker exec sonarr ping -c 2 prowlarr
docker exec sonarr ping -c 2 qbittorrent
```

**Service API connectivity:**
- Verify Sonarr can reach qBittorrent API
- Verify Radarr can reach qBittorrent API
- Verify Prowlarr syncs to Sonarr/Radarr

### VPN Connectivity Verification

**Critical verification after Chapter 7:**
```bash
# Check VPN container is running
docker ps | grep nordlynx

# Check VPN IP (should be different from server IP)
docker exec nordlynx curl -s https://ifconfig.io

# Verify qBittorrent traffic goes through VPN
docker exec qbittorrent curl -s https://ifconfig.io
```

**Expected:** VPN IP should be different from server's public IP

### Storage Verification

**Check directory structure:**
```bash
ls -la /data/media/movies
ls -la /data/media/tv
ls -la ~/downloads/complete
ls -la ~/downloads/incomplete
ls -la ~/mediaserver/config
```

**Check permissions:**
```bash
ls -la ~/mediaserver/config | head -10
```

**Expected:** Directories exist with correct ownership (matching PUID/PGID)

### Complete System Verification (Chapter 21)

**Run comprehensive checks:**
1. All services running
2. All web interfaces accessible
3. VPN working
4. Inter-service connectivity
5. Storage accessible
6. Test download workflow (if user has indexers configured)
7. Test import workflow
8. Plex library scanning

## Error Handling

### Common Issues Reference

**Always check [Appendix C: Troubleshooting](appendices/C-troubleshooting.md) first** when errors occur.

### Reading Logs

**Docker container logs:**
```bash
docker logs containername --tail 50
docker logs containername --tail 100 -f  # Follow logs
docker compose logs servicename
```

**System service logs:**
```bash
sudo journalctl -u servicename -n 50
sudo journalctl -u servicename -f  # Follow logs
```

**System logs:**
```bash
sudo dmesg | tail -50
sudo tail -50 /var/log/syslog
```

### When to Ask User for Help

**Ask user when:**
- Error requires physical access to server
- Error requires router access (user must do manually)
- Error requires account access (NordVPN, DNS provider)
- Error is unclear and troubleshooting doesn't help
- Multiple fix attempts have failed

**Attempt fixes yourself when:**
- Clear configuration errors
- Permission issues
- Service restart needed
- Missing dependencies
- Network connectivity within server

### Rollback Procedures

**Before making changes:**
- Document current state
- Backup configuration files if modifying
- Note current service status

**If changes fail:**
- Restore configuration files from backup
- Restart affected services
- Revert to last known good state
- Report to user what was changed and reverted

**Example rollback:**
```bash
# If Docker Compose changes break services
cd ~/mediaserver
docker compose down
# Restore previous docker-compose.yml
docker compose up -d
```

## Configuration Management

### Using Configuration Templates

**Location:** All templates are in `configs/` directory

**Key files:**
- `docker-compose.yml` - Main service stack
- `example.env` - Environment variables template
- `Caddyfile.example` - Reverse proxy config (if using)
- `ddns-config.json.example` - DDNS config (if using)

### Required Customizations

**Environment file (`.env`):**
- `PUID` - User ID (run `id` command)
- `PGID` - Group ID (run `id` command)
- `TZ` - Timezone (e.g., `America/New_York`)
- `WIREGUARD_PRIVATE_KEY` - NordVPN key (from Appendix A)
- `DOWNLOADS_PATH` - Full path to downloads directory
- `MEDIA_PATH` - Full path to media directory
- `CONFIG_PATH` - Full path to config directory

**Docker Compose file:**
- Update volume paths to match user's actual paths
- Update any user-specific configurations
- Comment out optional services if user doesn't want them

**Caddyfile (if using):**
- Replace `example.com` with user's domain
- Update service URLs if needed
- Configure email for Let's Encrypt (optional but recommended)

### Security Considerations

**File permissions:**
```bash
# .env file should be restricted
chmod 600 ~/mediaserver/.env

# Config directories should be owned by user
sudo chown -R $USER:$USER ~/mediaserver/config
sudo chown -R $USER:$USER ~/downloads
```

**Never commit secrets:**
- Warn user not to commit `.env` file to version control
- Ensure sensitive files have correct permissions
- Don't log secrets in output

### Environment Variable Handling

**Always:**
- Use actual values, not placeholders
- Verify values are correct before using
- Check that paths exist before using in volumes
- Validate format (especially WireGuard key)

**Example:**
```bash
# Get user's actual IDs
id
# Output: uid=1000(username) gid=1000(username) groups=1000(username),27(sudo),...

# Use in .env
PUID=1000
PGID=1000
```

## Architecture Understanding

### Native vs Docker Services

**Plex runs natively (not in Docker):**
- **Why:** Better hardware transcoding performance
- **Direct access to:** Intel Quick Sync Video (QSV)
- **Update method:** Standard apt package updates
- **Service management:** systemd (`systemctl`)

**All other services run in Docker:**
- **Why:** Easy management, isolation, consistent environments
- **Update method:** `docker compose pull && docker compose up -d`
- **Service management:** Docker Compose

### Network Architecture

**Key concepts:**
- **VPN isolation:** qBittorrent shares network with nordlynx container
- **Port assignments:** See [Appendix D](appendices/D-service-ports-reference.md)
- **Local vs remote:** Most services only accessible on LAN
- **qBittorrent security:** Only accessible via localhost (SSH tunnel required)

**Network flow:**
```
Internet → Router → Server
  ├─ Port 32400 → Plex (direct)
  ├─ Port 80/443 → Caddy (optional) → Internal services
  └─ Port 8989, 7878, etc. → Services (LAN only)
```

**VPN flow:**
```
qBittorrent → nordlynx container → NordVPN server → Internet
```

### Storage Architecture

**SSD (Fast storage):**
- Operating system
- Downloads (`~/downloads/complete`, `~/downloads/incomplete`)
- Service configurations (`~/mediaserver/config/`)

**HDD (Large storage):**
- Media library (`/data/media/movies`, `/data/media/tv`)
- Long-term storage

**Why this separation:**
- Torrent downloads involve random I/O (better on SSD)
- Media files are sequential (fine on HDD)
- Config databases benefit from fast storage

### Service Dependencies

**Data flow:**
1. User requests content (Jellyseerr, optional)
2. Sonarr/Radarr search for content
3. Prowlarr queries indexers
4. qBittorrent downloads (through VPN)
5. Sonarr/Radarr import and rename
6. Files moved to `/data/media/`
7. Plex scans and adds to library

**Service startup order:**
- nordlynx (VPN) must start first
- qBittorrent depends on nordlynx
- Sonarr/Radarr depend on qBittorrent and Prowlarr
- Prowlarr can start independently
- Caddy depends on services being ready

**Docker Compose handles dependencies automatically** via `depends_on` directives.

## Best Practices

### Always Verify Prerequisites

Before each chapter:
1. Check prerequisites listed in chapter
2. Verify previous chapters completed
3. Test that required services are running
4. Confirm required files/directories exist

### Test Incrementally

After each major component:
1. Verify service starts successfully
2. Test basic functionality
3. Check logs for errors
4. Confirm connectivity
5. Report status to user

### Document User-Specific Values

Keep track of:
- Username
- Paths (downloads, media, config)
- IP addresses
- Domain name (if applicable)
- PUID/PGID
- Timezone
- Optional features enabled

### Maintain Security

**Always:**
- Set correct file permissions (especially `.env`)
- Never log or expose secrets
- Use SSH keys, not passwords
- Keep services updated
- Follow security best practices from guide

### Provide Clear Progress Updates

**Format:**
- ✓ Completed steps
- → Next steps
- ⏸ Waiting for user input
- ❌ Errors encountered
- ⚠️ Warnings

**Example:**
```
Progress Update:

✓ Chapter 1: Hardware planning complete
✓ Chapter 2: Ubuntu installed (user confirmed)
✓ Chapter 3: Docker installed and verified
→ Chapter 4: SSH Security
⏸ Waiting for: Your approval to proceed with SSH hardening

Current status: All foundation services ready. Next step requires your approval.
```

### Handle User Questions

**When user asks questions:**
1. Reference relevant guide chapter
2. Check troubleshooting appendix
3. Provide clear, actionable answers
4. If unsure, admit it and suggest where to find answer

### Respect User Decisions

**Always:**
- Honor user's choices on optional features
- Don't enable features user doesn't want
- Ask before making assumptions
- Respect user's hardware/network constraints

## Quick Reference

### Essential Commands

**Service management:**
```bash
# Native services
sudo systemctl status servicename
sudo systemctl restart servicename

# Docker services
docker compose ps
docker compose restart servicename
docker compose logs servicename
```

**Verification:**
```bash
# Check all services
docker compose ps
systemctl is-active plexmediaserver

# Check VPN
docker exec nordlynx curl -s https://ifconfig.io

# Check disk space
df -h
```

**Troubleshooting:**
```bash
# View logs
docker logs containername --tail 50
sudo journalctl -u servicename -n 50

# Check connectivity
docker exec sonarr ping radarr
curl -I http://server-ip:PORT
```

### Key File Locations

- Environment: `~/mediaserver/.env`
- Docker Compose: `~/mediaserver/docker-compose.yml`
- Configs: `~/mediaserver/config/`
- Downloads: `~/downloads/`
- Media: `/data/media/`

### Important Ports

- 32400: Plex
- 8989: Sonarr
- 7878: Radarr
- 9696: Prowlarr
- 8080: qBittorrent (localhost only)
- 80/443: Caddy (if using)

See [Appendix D](appendices/D-service-ports-reference.md) for complete list.

## Getting Help

### For the Agent

**Reference materials:**
- Guide chapters in `guide/`
- Appendices in `appendices/`
- Architecture documentation in `ARCHITECTURE.md`
- Troubleshooting in `appendices/C-troubleshooting.md`

**When stuck:**
1. Re-read relevant guide chapter
2. Check troubleshooting appendix
3. Review architecture documentation
4. Ask user for clarification
5. Suggest user consult external resources if needed

### For the User

**Resources:**
- [Troubleshooting Appendix](appendices/C-troubleshooting.md)
- Service-specific documentation (links in guide)
- [r/selfhosted](https://reddit.com/r/selfhosted) community
- [r/PleX](https://reddit.com/r/PleX) for Plex-specific questions

---

**Remember:** This is a comprehensive guide. Take your time, verify each step, and always prioritize user understanding and system security. When in doubt, ask the user before proceeding.
