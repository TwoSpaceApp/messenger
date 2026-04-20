# Web Deployment Guide for TwoSpace Messenger

## Quick Start

To deploy TwoSpace web application to production:

```bash
# Build Flutter web
flutter build web --release

# Deploy to server
./scripts/deploy-web.sh

# Verify deployment
curl -I https://web.twospace.ru/
```

---

## Prerequisites

### Local Machine
- Flutter 3.38.8+
- Dart 3.10.7+
- `rsync` tool

### Server
- Ubuntu 20.04+
- nginx 1.24+
- Node.js 18+
- SSL certificates (Let's Encrypt or similar)

---

## Complete Deployment Steps

### Step 1: Build Flutter Web

```bash
cd /path/to/messenger
flutter pub get
flutter build web --release
```

This produces optimized production build in `build/web/`:
- ~43 MB total size
- ~8.8 MB main.dart.js
- All assets tree-shaken for web platform

### Step 2: Configure WebSocket Proxy

The web application communicates via WebSocket to bridge the gap between browser and native TCP Aegis server.

**Server Setup:**

1. Install Node.js and npm:
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

2. Create proxy directory:
```bash
sudo mkdir -p /opt/websocket-proxy
sudo chown root:root /opt/websocket-proxy
```

3. Copy proxy files:
```bash
sudo cp websocket-proxy.js /opt/websocket-proxy/
sudo cp package.json /opt/websocket-proxy/
```

4. Install dependencies:
```bash
cd /opt/websocket-proxy
sudo npm install
```

5. Install systemd service:
```bash
sudo cp twospace-ws-proxy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable twospace-ws-proxy
sudo systemctl start twospace-ws-proxy
```

Verify proxy is running:
```bash
systemctl status twospace-ws-proxy
ss -tlnp | grep 9999
```

### Step 3: Configure nginx

nginx acts as the main web server and reverse proxy for WebSocket.

**Configuration locations:**
- Available configs: `/etc/nginx/sites-available/`
- Enabled configs: `/etc/nginx/sites-enabled/`
- Main config: `/etc/nginx/nginx.conf`

**Setup:**

1. Deploy configuration:
```bash
sudo cp web.twospace.ru.nginx /etc/nginx/sites-available/web.twospace.ru
```

2. Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/web.twospace.ru /etc/nginx/sites-enabled/
```

3. Test configuration:
```bash
sudo nginx -t
```

4. Reload nginx:
```bash
sudo systemctl reload nginx
```

**Key nginx features:**
- HTTPS with Let's Encrypt certificates
- HTTP → HTTPS redirect (301)
- WebSocket proxy at `/ws` endpoint
- SPA routing fallback to `/index.html`
- Long-lived connection support (timeouts: 7 days)
- Asset caching (1 year for versioned files)

### Step 4: Deploy Web Files

Deploy the Flutter web build to the web server:

```bash
rsync -avz --delete build/web/ root@YOUR_SERVER:/var/www/web.twospace.ru/
```

Verify deployment:
```bash
ssh root@YOUR_SERVER "ls -la /var/www/web.twospace.ru/"
```

### Step 5: Configure SSL Certificates

If using Let's Encrypt:

```bash
# Install Certbot (if not already installed)
sudo apt-get install -y certbot python3-certbot-nginx

# Request certificate
sudo certbot certonly --nginx -d web.twospace.ru

# Nginx SSL settings (already in config)
# - Certificate: /etc/letsencrypt/live/web.twospace.ru/fullchain.pem
# - Key: /etc/letsencrypt/live/web.twospace.ru/privkey.pem

# Auto-renewal (already configured by certbot)
sudo systemctl status certbot.timer
```

---

## Troubleshooting

### Issue: "Failed to connect" in browser console

**Cause:** WebSocket proxy not running or port not accessible

**Solution:**
```bash
# Check if proxy is running
systemctl status twospace-ws-proxy

# Check port binding
ss -tlnp | grep 9999

# Check nginx upstream
curl -I http://localhost:9999/

# View proxy logs
journalctl -u twospace-ws-proxy -f
```

### Issue: "Connection refused" on localhost:8888

**Cause:** Aegis server not running on port 8888

**Solution:**
- Verify Aegis server is running and listening on port 8888
- Check firewall rules: `sudo ufw allow 8888/tcp`

### Issue: HTTPS certificate errors

**Cause:** Outdated browser cache or certificate expiration

**Solution:**
```bash
# Check certificate expiry
sudo certbot certificates

# Force renewal
sudo certbot renew --force-renewal

# Clear browser cache and hard-refresh (Ctrl+Shift+R)
```

### Issue: 502 Bad Gateway on /ws requests

**Cause:** nginx cannot reach WebSocket backend

**Solution:**
```bash
# Verify nginx config
sudo nginx -t

# Check upstream connectivity
curl -v http://localhost:9999/

# Monitor nginx error log
sudo tail -f /var/log/nginx/error.log
```

---

## Performance Optimization

### Browser Cache

Static assets (JS, CSS, images) are cached for 1 year:
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

For updates, Flutter's build system automatically versioned filenames.

### Compression

nginx gzip compression is enabled by default for:
- text/plain
- text/css
- application/json
- application/javascript

### Database

On web, use lightweight in-memory state instead of heavy database queries (already configured via Drift conditionals).

---

## Monitoring

### View access logs
```bash
sudo tail -f /var/log/nginx/access.log
```

### View error logs
```bash
sudo tail -f /var/log/nginx/error.log
```

### Monitor services
```bash
systemctl status nginx
systemctl status twospace-ws-proxy
```

### Monitor proxy connections
```bash
netstat -antp | grep 9999
ss -antp | grep ESTABLISHED | grep 9999
```

---

## Environment Variables

**WebSocket Proxy** (`twospace-ws-proxy.service`):
- `WS_PORT=9999` - Port for WebSocket server
- `TCP_HOST=localhost` - Backend Aegis server host
- `TCP_PORT=8888` - Backend Aegis server port
- `USE_SSL=false` - WebSocket SSL/TLS (usually handled by nginx)

---

## Architecture Overview

```
Browser (Flutter Web App)
    ↓ HTTPS
nginx (port 443)
    ↓ HTTP
nginx upstream: localhost:9999
    ↓
WebSocket Proxy (Node.js)
    ↓ TCP
Aegis Server (port 8888)
```

---

## Rollback Procedure

If deployment has issues:

```bash
# Stop services
sudo systemctl stop twospace-ws-proxy
sudo systemctl reload nginx

# Restore previous build (if available)
rsync -avz --delete backup/web/ root@YOUR_SERVER:/var/www/web.twospace.ru/

# Restart services
sudo systemctl start twospace-ws-proxy
sudo systemctl reload nginx
```

---

## Next Steps

1. **Monitor live site**: https://web.twospace.ru/
2. **Check browser console** for any connection errors (F12)
3. **Test WebSocket connection**: Check DevTools Network tab
4. **Validate auth flow**: Test login and session management
5. **Performance metrics**: Monitor page load times and WebSocket latency

For more details on architecture, see [WebSocket Architecture](./architecture/websocket-architecture.md).
