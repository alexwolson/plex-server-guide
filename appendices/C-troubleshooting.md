# Appendix C: Troubleshooting

This appendix covers common problems and their solutions.

## Quick Diagnostics

### Check Everything at Once

```bash
cd ~/mediaserver
echo "=== Docker Status ==="
docker compose ps
echo ""
echo "=== VPN Status ==="
docker exec nordlynx curl -s https://ifconfig.io 2>/dev/null || echo "VPN not reachable"
echo ""
echo "=== Disk Space ==="
df -h / /data 2>/dev/null || df -h /
echo ""
echo "=== Recent Errors ==="
docker compose logs --tail 5 2>&1 | grep -i error | head -10
```

## Docker Issues

### Container Won't Start

**Symptoms:** Container shows "Restarting" or "Exited"

**Check logs:**
```bash
docker logs container-name --tail 100
```

**Common causes:**
1. Configuration file syntax error
2. Port already in use
3. Volume mount path doesn't exist
4. Permission issues

**Solutions:**
```bash
# Check port conflicts
sudo netstat -tlnp | grep :PORT

# Verify volume path exists
ls -la /path/to/volume

# Check permissions
ls -la ~/mediaserver/config/
```

### "Permission Denied" Errors

**Check PUID/PGID in .env:**
```bash
id
cat ~/mediaserver/.env | grep -E "PUID|PGID"
```

**Fix ownership:**
```bash
sudo chown -R $USER:$USER ~/mediaserver/config
sudo chown -R $USER:$USER ~/downloads
```

### Container Can't Reach Another Container

**Verify both are on same network:**
```bash
docker network inspect mediaserver_default
```

**Test connectivity:**
```bash
docker exec sonarr ping radarr
```

### Docker Daemon Not Running

```bash
sudo systemctl status docker
sudo systemctl start docker
```

## VPN Issues

### VPN Not Connecting

**Check logs:**
```bash
docker logs nordlynx --tail 50
```

**Verify WireGuard key:**
```bash
cat ~/mediaserver/.env | grep WIREGUARD
```

**Common errors:**

| Error | Solution |
|-------|----------|
| "Invalid private key" | Regenerate key (see Appendix A) |
| "No endpoints" | Check NordVPN subscription is active |
| "Operation not permitted" | Ensure NET_ADMIN capability |

### VPN Connected But No Internet

**Check DNS:**
```bash
docker exec nordlynx cat /etc/resolv.conf
docker exec nordlynx nslookup example.com
```

**Check routing:**
```bash
docker exec nordlynx ip route
```

### IP Leaking (Shows Home IP)

1. **Stop all downloads immediately**
2. Check nordlynx is running
3. Restart nordlynx:
   ```bash
   docker compose restart nordlynx
   ```
4. Verify VPN before resuming:
   ```bash
   docker exec nordlynx curl -s https://ifconfig.io
   ```

## SSL/HTTPS Issues

### Certificate Not Issued

**Check Caddy logs:**
```bash
docker logs caddy 2>&1 | grep -i "error\|certificate"
```

**Common causes:**
1. DNS not pointing to your IP
2. Ports 80/443 not forwarded
3. Rate limited by Let's Encrypt

**Verify DNS:**
```bash
dig +short your-domain.com
curl -s https://ifconfig.io
# These should match
```

### Certificate Expired

**Force renewal:**
```bash
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### "Connection Not Private" Error

1. Check certificate is valid:
   ```bash
   echo | openssl s_client -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates
   ```

2. Clear browser cache

3. Try incognito mode

## Download Issues

### Downloads Not Starting

**Check qBittorrent:**
1. Access via SSH tunnel:
   ```bash
   ssh -L 8080:localhost:8080 user@server
   ```
2. Open `http://localhost:8080`
3. Check for paused torrents or errors

**Check VPN:**
```bash
docker exec nordlynx wg show
```

**Check indexers:**
- Open Prowlarr
- Test each indexer

### Downloads Complete But Don't Import

**Check Sonarr/Radarr Activity:**
- Look for import errors in Activity > Queue
- Common issues: permissions, path mismatch, file already exists

**Verify paths match:**
- Download path in qBittorrent: `/downloads/complete`
- Download path in Sonarr: `/downloads`
- These must align

**Check permissions:**
```bash
ls -la ~/downloads/complete/
docker exec sonarr ls -la /downloads/complete/
```

### Slow Downloads

1. Check VPN server (some are slower)
2. Verify seeders available
3. Check internet connection
4. Consider changing NordVPN server:
   ```yaml
   environment:
     - QUERY=filters\[servers_groups\]\[identifier\]=legacy_p2p&filters\[country_id\]=228
   ```

## Plex Issues

### Plex Not Finding Media

**Trigger library scan:**
```bash
curl "http://localhost:32400/library/sections/1/refresh?X-Plex-Token=YOUR_TOKEN"
```

**Check file permissions:**
```bash
sudo -u plex ls /data/media/movies/
```

**Fix if needed:**
```bash
sudo chmod -R 755 /data/media
```

### Hardware Transcoding Not Working

**Verify Intel graphics available:**
```bash
ls -la /dev/dri/
```

**Check plex user in render group:**
```bash
groups plex
# Should include 'render'

# If not:
sudo usermod -aG render plex
sudo systemctl restart plexmediaserver
```

### Remote Access Not Working

1. Check port 32400 is forwarded
2. Verify in Plex settings:
   ```
   Settings > Remote Access > Show Advanced
   ```
3. Test with [canyouseeme.org](https://canyouseeme.org) port 32400

## SSH Issues

### Can't Connect

**If you can access console:**
```bash
# Check SSH service
sudo systemctl status ssh

# Check your IP isn't banned
sudo fail2ban-client status sshd

# Temporarily disable hardening (emergency)
sudo mv /etc/ssh/sshd_config.d/99-hardened.conf /etc/ssh/sshd_config.d/99-hardened.conf.bak
sudo systemctl restart ssh
```

### Locked Out by fail2ban

**From console:**
```bash
sudo fail2ban-client set sshd unbanip YOUR_IP
```

### Key Not Accepted

1. Check key permissions on client:
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   ```

2. Check authorized_keys on server:
   ```bash
   cat ~/.ssh/authorized_keys
   ```

3. Check SSH agent:
   ```bash
   ssh-add -l
   ssh-add ~/.ssh/id_ed25519
   ```

## Disk Space Issues

### Running Out of Space

**Find large files:**
```bash
du -sh /data/media/* | sort -h
du -sh ~/downloads/* | sort -h
```

**Clean Docker:**
```bash
docker system prune -a
```

**Check for stuck downloads:**
```bash
ls -la ~/downloads/incomplete/
```

### Downloads Folder Growing

Sonarr/Radarr should clean up after import. If not:

1. Check Activity queue for errors
2. Verify "Remove" is enabled in download client settings
3. Manually clean up:
   ```bash
   rm -rf ~/downloads/complete/*
   ```

## Network Issues

### Can't Access Services Locally

**Check service is listening:**
```bash
sudo netstat -tlnp | grep LISTEN
```

**Check firewall:**
```bash
sudo ufw status
# If active and blocking:
sudo ufw allow PORT/tcp
```

### Can't Access Remotely

1. Check port forwarding on router
2. Verify DDNS is updating
3. Check Caddy is running
4. Test from outside network (phone on cellular)

### Slow Network Performance

1. Use ethernet instead of WiFi
2. Check for network congestion
3. Verify VPN isn't bottleneck:
   ```bash
   # Test without VPN
   curl -o /dev/null -w "%{speed_download}" https://speed.cloudflare.com/__down?bytes=100000000

   # Test through VPN
   docker exec nordlynx curl -o /dev/null -w "%{speed_download}" https://speed.cloudflare.com/__down?bytes=100000000
   ```

## Log Locations

| Service | Log Command |
|---------|-------------|
| Any Docker container | `docker logs container-name` |
| Plex | `/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Logs/` |
| System | `sudo journalctl -f` |
| SSH | `/var/log/auth.log` |
| fail2ban | `sudo fail2ban-client status sshd` |

## When All Else Fails

### Full Stack Restart

```bash
cd ~/mediaserver
docker compose down
docker compose up -d
```

### Rebuild Container

```bash
docker compose stop sonarr
docker compose rm sonarr
docker compose up -d sonarr
```

### Fresh Start (Last Resort)

```bash
# Backup first!
tar -czf ~/backup.tar.gz ~/mediaserver/config

# Remove and recreate
docker compose down -v
rm -rf ~/mediaserver/config/*
docker compose up -d
```

## Getting Help

If you're still stuck:

1. Check service-specific documentation
2. Search error message online
3. Ask in [r/selfhosted](https://reddit.com/r/selfhosted)
4. Check service's GitHub issues
5. Ask in service's Discord/forum
