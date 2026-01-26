# Chapter 22: Maintenance

Your media server is running. This chapter covers ongoing maintenance to keep it healthy.

## Overview

Regular maintenance tasks:
- Updating containers and system packages
- Monitoring disk space
- Backing up configurations
- Troubleshooting common issues

## Updating Containers

### Update All Containers

```bash
cd ~/mediaserver
docker compose pull
docker compose up -d
```

This pulls the latest images and recreates containers with new versions.

### Update Specific Container

```bash
docker compose pull sonarr
docker compose up -d sonarr
```

### Check for Updates

```bash
docker compose pull --dry-run 2>&1 | grep -v "up to date"
```

Shows which containers have updates available.

### Recommended Update Schedule

| Component | Frequency | Notes |
|-----------|-----------|-------|
| Container images | Weekly | Most updates are safe |
| Ubuntu packages | Weekly | Security updates |
| Plex | As released | Native package updates itself |

## Updating Ubuntu

### Regular Updates

```bash
sudo apt update && sudo apt upgrade -y
```

### Automatic Security Updates

Enable unattended upgrades for security patches:

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Kernel Updates

After kernel updates, reboot when convenient:
```bash
sudo reboot
```

## Monitoring Disk Space

### Check Disk Usage

```bash
df -h /data/media ~/downloads
```

### Find Large Files

```bash
du -sh /data/media/* | sort -h
```

### Monitor Downloads Folder

Downloads should be imported and cleaned up automatically. If they accumulate:

```bash
ls -la ~/downloads/complete/
```

Check Sonarr/Radarr activity for stuck imports.

### Set Up Alerts (Optional)

Create a simple disk space check script:

```bash
mkdir -p ~/scripts
nano ~/scripts/check-disk.sh
```

Add the following content:

```bash
#!/bin/bash
THRESHOLD=90
USAGE=$(df /data | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$USAGE" -gt "$THRESHOLD" ]; then
  echo "Warning: Disk usage is ${USAGE}%"
fi
```

Save and exit (Ctrl+X, then Y, then Enter).

Make it executable:
```bash
chmod +x ~/scripts/check-disk.sh
```

Add to crontab to run daily:
```bash
crontab -e
# Add: 0 9 * * * /home/your-username/scripts/check-disk.sh
```

## Backing Up Configurations

### What to Back Up

| Directory | Contains |
|-----------|----------|
| `~/mediaserver/config/` | All service configs and databases |
| `~/mediaserver/.env` | Environment variables (contains secrets) |
| `~/mediaserver/Caddyfile` | Reverse proxy config |
| `/etc/ssh/sshd_config.d/` | SSH hardening |
| `/etc/fail2ban/jail.d/` | fail2ban config |

### Manual Backup

```bash
# Create backup directory
mkdir -p /data/backups/$(date +%Y%m%d)

# Stop services for consistent backup
cd ~/mediaserver
docker compose stop

# Backup configs
tar -czf /data/backups/$(date +%Y%m%d)/mediaserver-config.tar.gz \
  ~/mediaserver/config \
  ~/mediaserver/.env \
  ~/mediaserver/Caddyfile

# Restart services
docker compose up -d

echo "Backup complete: /data/backups/$(date +%Y%m%d)/"
```

### Automated Backup Script

Create the backup script:

```bash
nano ~/scripts/backup.sh
```

Add the following content:

```bash
#!/bin/bash
BACKUP_DIR="/data/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

cd ~/mediaserver
docker compose stop
tar -czf "$BACKUP_DIR/mediaserver-config.tar.gz" config .env Caddyfile
docker compose up -d

# Keep only last 7 backups
find /data/backups -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;

echo "Backup saved to $BACKUP_DIR"
```

Save and exit (Ctrl+X, then Y, then Enter).

Make it executable:
```bash
chmod +x ~/scripts/backup.sh
```

Add to crontab for weekly backup:
```bash
crontab -e
# Add: 0 3 * * 0 /home/your-username/scripts/backup.sh
```

### Plex Backup

Plex metadata is stored separately:
```bash
sudo tar -czf /data/backups/$(date +%Y%m%d)/plex-library.tar.gz \
  /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/
```

> **Note:** This can be large. Consider backing up only Preferences and databases, not cache.

## Viewing Logs

### Docker Container Logs

```bash
# View last 100 lines
docker logs sonarr --tail 100

# Follow logs in real-time
docker logs -f sonarr

# View logs with timestamps
docker logs --timestamps sonarr --tail 50
```

### System Logs

```bash
# SSH authentication
sudo tail -f /var/log/auth.log

# System messages
sudo journalctl -f

# Docker daemon
sudo journalctl -u docker -f
```

## Common Maintenance Tasks

### Restart a Stuck Service

```bash
docker compose restart sonarr
```

### Rebuild a Container

If a container is misbehaving:
```bash
docker compose stop sonarr
docker compose rm sonarr
docker compose up -d sonarr
```

### Clean Up Docker

Remove unused images and containers:
```bash
docker system prune -a
```

> **Warning:** This removes all unused images. Run only when you don't need to quickly rollback.

### Check Service Health

```bash
# Container resource usage
docker stats --no-stream

# Service status
docker compose ps
```

## Troubleshooting Common Issues

### Container Keeps Restarting

1. Check logs:
   ```bash
   docker logs container-name --tail 50
   ```

2. Common causes:
   - Configuration error
   - Permission issues
   - Missing dependencies

### Downloads Not Importing

1. Check Sonarr/Radarr Activity queue
2. Verify permissions on download folder
3. Check disk space
4. Look for errors in logs

### VPN Disconnects

1. Check nordlynx logs:
   ```bash
   docker logs nordlynx --tail 50
   ```

2. Restart nordlynx:
   ```bash
   docker compose restart nordlynx
   ```

3. Verify WireGuard key is still valid

### Plex Not Scanning New Media

1. Manual library scan in Plex Web
2. Check Plex logs:
   ```bash
   sudo tail -f /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Logs/Plex\ Media\ Server.log
   ```

3. Verify file permissions

### SSL Certificate Issues

1. Check Caddy logs:
   ```bash
   docker logs caddy --tail 50
   ```

2. Force certificate renewal:
   ```bash
   docker exec caddy caddy reload --config /etc/caddy/Caddyfile
   ```

## Performance Tuning

### If Server Feels Slow

1. Check resource usage:
   ```bash
   htop
   docker stats
   ```

2. Common bottlenecks:
   - RAM: Add more or reduce services
   - CPU: Hardware transcoding not working?
   - Disk: HDD too slow for many concurrent streams

### Optimize Plex

1. Enable hardware transcoding (if not already)
2. Reduce simultaneous transcodes
3. Lower remote stream quality

## Security Maintenance

### Review fail2ban

```bash
sudo fail2ban-client status sshd
```

### Check for Banned IPs

```bash
sudo fail2ban-client status sshd | grep "Banned IP"
```

### Unban an IP (if needed)

```bash
sudo fail2ban-client set sshd unbanip 1.2.3.4
```

### Review SSH Access

```bash
# Recent logins
last -10

# Failed login attempts
sudo grep "Failed password" /var/log/auth.log | tail -20
```

## When Things Go Wrong

### Recovery Checklist

1. **Can't SSH in?**
   - Connect monitor/keyboard directly
   - Check fail2ban hasn't banned you
   - Verify SSH service is running

2. **Services not starting?**
   - Check Docker is running: `systemctl status docker`
   - Check disk space: `df -h`
   - Review logs: `docker logs container-name`

3. **Lost configuration?**
   - Restore from backup
   - Check if docker volumes still exist

### Emergency Restore

```bash
# Stop services
cd ~/mediaserver
docker compose down

# Restore config
tar -xzf /data/backups/YYYYMMDD/mediaserver-config.tar.gz -C /

# Start services
docker compose up -d
```

## Quick Reference

| Task | Command |
|------|---------|
| Update containers | `docker compose pull && docker compose up -d` |
| Update Ubuntu | `sudo apt update && sudo apt upgrade -y` |
| Check disk space | `df -h` |
| View container logs | `docker logs container-name --tail 100` |
| Restart service | `docker compose restart service-name` |
| Backup configs | `tar -czf backup.tar.gz ~/mediaserver/config` |

## Conclusion

Congratulations! You've built a complete home media server with:

- Automated TV and movie downloads
- VPN-protected downloads
- Secure remote access
- Automatic subtitle downloads
- User request management

Enjoy your media server!

---

**Previous:** [Chapter 21: Verification Checklist](21-verification-checklist.md)

**Back to:** [README](../README.md)
