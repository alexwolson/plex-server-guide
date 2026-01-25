# Appendix A: Getting Your NordVPN WireGuard Private Key

The nordlynx container requires a WireGuard private key from your NordVPN account. This appendix explains how to obtain it.

## Overview

NordVPN uses the WireGuard protocol under the name "NordLynx". To use it with the nordlynx Docker container, you need to extract your private key.

## Prerequisites

- Active NordVPN subscription
- Access to your NordVPN account

## Method 1: Access Token Method (Recommended)

This method uses NordVPN's API to generate credentials.

### Step 1: Log into NordVPN

1. Go to [my.nordaccount.com](https://my.nordaccount.com)
2. Sign in with your NordVPN credentials

### Step 2: Generate Access Token

1. Go to **Services** > **NordVPN**
2. Scroll to **Manual setup**
3. Click **Set up NordVPN manually**
4. Under **Access Token**, click **Generate New Token**
5. Copy the token (it's only shown once)

### Step 3: Convert Token to Private Key

Run a temporary container to convert the token:

```bash
docker run --rm --cap-add=NET_ADMIN -e TOKEN="your-access-token-here" ghcr.io/bubuntux/nordlynx
```

Wait for it to connect, then check the logs:
```bash
docker logs <container-id> 2>&1 | grep PRIVATE_KEY
```

Or use this one-liner:
```bash
docker run --rm --cap-add=NET_ADMIN -e TOKEN="your-access-token-here" ghcr.io/bubuntux/nordlynx sh -c "sleep 30 && cat /etc/wireguard/wg0.conf | grep PrivateKey"
```

Copy the private key value.

### Step 4: Use the Private Key

Add to your `~/mediaserver/.env`:
```
WIREGUARD_PRIVATE_KEY=your-private-key-here
```

## Method 2: Using NordVPN Linux Client

If you have the NordVPN Linux client installed elsewhere:

### Step 1: Install NordVPN Client

On any Linux machine (doesn't have to be your server):

```bash
curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh | sh
```

### Step 2: Log In and Connect

```bash
nordvpn login
nordvpn set technology nordlynx
nordvpn connect
```

### Step 3: Extract the Key

```bash
sudo cat /var/lib/nordvpn/data/settings.dat | grep -o '"private_key":"[^"]*"' | cut -d'"' -f4
```

Or:
```bash
sudo wg show nordlynx private-key
```

### Step 4: Use the Key

Copy the private key to your `.env` file.

## Method 3: Using the nordlynx Container with Token

The nordlynx container can also accept a token directly:

```yaml
environment:
  - TOKEN=your-access-token-here
```

The container will automatically convert this to a private key.

However, using `PRIVATE_KEY` directly is recommended because:
- Faster container startup
- Doesn't require re-authentication
- More reliable

## Verifying Your Key

After setting up, verify the VPN is working:

```bash
docker compose up -d nordlynx
sleep 10
docker exec nordlynx curl -s https://ifconfig.io
```

Should return a NordVPN IP (not your home IP).

Check WireGuard status:
```bash
docker exec nordlynx wg show
```

Should show an active interface with handshake.

## Token vs Private Key

| Method | Pros | Cons |
|--------|------|------|
| TOKEN | Simpler setup | Slower startup, needs internet |
| PRIVATE_KEY | Faster, more reliable | Extra step to extract |

## Troubleshooting

### "Invalid Token"

- Tokens expire - generate a new one
- Check for extra spaces or newlines
- Ensure token is complete (they're long)

### "No endpoints available"

- NordVPN service may be down
- Try different server query:
  ```yaml
  environment:
    - QUERY=filters\[servers_groups\]\[identifier\]=legacy_p2p
  ```

### VPN Connects But No Internet

1. Check sysctls are set in docker-compose.yml
2. Verify NET_ADMIN capability is added
3. Check DNS resolution inside container

### Key Not Working After Months

NordVPN keys can expire or be rotated. Generate a new access token and extract a fresh private key.

## Security Notes

- **Never share your private key**
- Keep `.env` file secure (chmod 600)
- Don't commit `.env` to version control
- Regenerate if you suspect compromise

## Quick Reference

| Item | Value/Location |
|------|----------------|
| NordVPN Account | [my.nordaccount.com](https://my.nordaccount.com) |
| Access Token Page | Services > NordVPN > Manual setup |
| Environment Variable | `WIREGUARD_PRIVATE_KEY` |
| Alternative | `TOKEN` (access token directly) |

## Next Steps

Once you have your private key, continue with [Chapter 7: Docker Compose Stack](../guide/07-docker-compose-stack.md).
