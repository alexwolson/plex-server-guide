# Chapter 4: SSH Security

Securing SSH is critical because your server will be accessible from the internet. We'll disable password authentication and install fail2ban to protect against brute-force attacks.

## Overview

By the end of this chapter:

- SSH will only accept key-based authentication (no passwords)
- Root login will be disabled
- fail2ban will automatically block IPs that fail too many login attempts

## Prerequisites

- Ubuntu Server LTS with SSH installed ([Chapter 2](02-install-ubuntu.md))
- Docker installed ([Chapter 3](03-install-docker.md))
- A computer with SSH access to your server

## Part 1: Set Up SSH Keys

If you already have SSH keys and can log in with them, skip to [Part 2](#part-2-harden-ssh-configuration).

### On Your Local Computer

#### Check for Existing Keys

```bash
ls -la ~/.ssh/
```

If you see `id_rsa` and `id_rsa.pub` (or `id_ed25519` and `id_ed25519.pub`), you already have keys.

#### Generate New Keys (if needed)

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Press Enter to accept the default location. Optionally set a passphrase for extra security.

### Copy Your Public Key to the Server

From your local computer:

```bash
ssh-copy-id your-username@<server-ip>
```

Enter your server password when prompted.

### Test Key-Based Login

```bash
ssh your-username@<server-ip>
```

If you're not prompted for a password, key-based authentication is working.

## Part 2: Harden SSH Configuration

### Create the SSH Hardening Config

On your server, create a new SSH configuration file:

```bash
sudo nano /etc/ssh/sshd_config.d/99-hardened.conf
```

Add the following content (replacing `your-username` with your actual username):

```
# SSH Hardening Config
# Disable password authentication (key-only)
PasswordAuthentication no
KbdInteractiveAuthentication no

# Disable root login
PermitRootLogin no

# Only allow specific user(s) - CHANGE THIS to your actual username
AllowUsers your-username
```

> **Important:** Make sure to change `your-username` in the `AllowUsers` line to your actual username (e.g., `AllowUsers alex`).

Save and exit (Ctrl+X, then Y, then Enter).

### Test the Configuration

Before restarting SSH, verify the configuration is valid:

```bash
sudo sshd -t
```

This should produce no output if the configuration is valid.

### Restart SSH

> **Warning:** Keep your current SSH session open! Open a **new terminal window** to test before closing this one.

```bash
sudo systemctl restart ssh
```

### Test the New Configuration

In a **new terminal window**, verify you can still connect:

```bash
ssh your-username@<server-ip>
```

If this works, your key-based authentication is configured correctly.

### Verify Password Authentication is Disabled

Try to connect with password authentication explicitly disabled:

```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no your-username@<server-ip>
```

This should be rejected immediately (not prompted for a password). You should see:
```
Permission denied (publickey).
```

## Part 3: Install fail2ban

fail2ban monitors log files and automatically bans IPs that show malicious signs (like too many failed login attempts).

### Install fail2ban

```bash
sudo apt update && sudo apt install -y fail2ban
```

### Create fail2ban Configuration for SSH

```bash
sudo nano /etc/fail2ban/jail.d/ssh.local
```

Add the following content:

```
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 600
bantime = 3600
```

Save and exit (Ctrl+X, then Y, then Enter).

This configuration:
- **maxretry = 5** - Ban after 5 failed attempts
- **findtime = 600** - Within a 10-minute window
- **bantime = 3600** - Ban for 1 hour

### Enable and Start fail2ban

```bash
sudo systemctl enable --now fail2ban
```

## Verification

### Check SSH Service

```bash
systemctl is-active ssh
```
Expected output: `active`

### Check fail2ban Service

```bash
systemctl is-active fail2ban
```
Expected output: `active`

### Check fail2ban SSH Jail Status

```bash
sudo fail2ban-client status sshd
```

Expected output:
```
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     0
|  `- File list:        /var/log/auth.log
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:
```

### View the Hardened SSH Config

```bash
cat /etc/ssh/sshd_config.d/99-hardened.conf
```

Verify your username is correct in the `AllowUsers` line.

## Troubleshooting

### Locked Out of SSH

If you accidentally locked yourself out:

1. You'll need physical access to the server (keyboard and monitor)
2. Log in at the console
3. Fix the SSH configuration:
   ```bash
   sudo nano /etc/ssh/sshd_config.d/99-hardened.conf
   ```
4. Restart SSH:
   ```bash
   sudo systemctl restart ssh
   ```

### fail2ban Banned Your IP

If you got banned while testing:

```bash
# View banned IPs
sudo fail2ban-client status sshd

# Unban an IP
sudo fail2ban-client set sshd unbanip <your-ip>
```

### SSH Key Not Working

1. Check key permissions on your local machine:
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```

2. Check authorized_keys on the server:
   ```bash
   ls -la ~/.ssh/authorized_keys
   ```
   Should be `600` or `644` permissions.

3. Check SSH agent is running:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

## Security Best Practices

Now that SSH is secured:

- **Never share your private key** (`id_ed25519` or `id_rsa`)
- **Back up your keys** in a secure location
- **Use a passphrase** on your private key for extra security
- **Regularly review** `/var/log/auth.log` for suspicious activity

## Next Steps

SSH is now secured with key-only authentication and fail2ban protection. Next, we'll set up the storage directories for media and downloads.

---

**Previous:** [Chapter 3: Install Docker](03-install-docker.md)

**Next:** [Chapter 5: Storage Setup](05-storage-setup.md)
