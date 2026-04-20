# TwoSpace Wiki

Documentation and guides for TwoSpace development, deployment, and architecture.

## 📚 Contents

### Architecture
- [WebSocket Architecture](./architecture/websocket-architecture.md) - Complete technical reference for the web platform transport layer

### Deployment
- [Web Deployment Guide](../web-deployment.md) - Complete step-by-step deployment guide for production
  - Quick start
  - Prerequisites
  - Full deployment steps (build, proxy, nginx, SSL)
  - Troubleshooting
  - Performance optimization
  - Rollback procedures

### Configuration Files (Reference)
Located in `./deployment/` for reference:
- `nginx.conf` - nginx reverse proxy configuration with WebSocket support
- `websocket-proxy.js` - Node.js WebSocket-to-TCP bridge implementation
- `package.json` - Node.js dependencies for WebSocket proxy
- `twospace-ws-proxy.service` - systemd service unit for auto-restart

## 🚀 Quick Deploy

For the fastest deployment:

```bash
chmod +x scripts/deploy-web-quick.sh
./scripts/deploy-web-quick.sh <server_ip> <user>
```

Example:
```bash
./scripts/deploy-web-quick.sh 95.215.56.43 root
```

This will:
1. Build Flutter web release
2. Deploy to server via rsync
3. Verify the deployment

See [Web Deployment Guide](../web-deployment.md) for full details.

## 🏗️ Architecture Overview

```
Browser (Flutter Web App)
    ↓ HTTPS Connection
nginx (port 443) 
    ↓ HTTP Proxy
WebSocket Proxy (port 9999)
    ↓ TCP Connection
Aegis Server (port 8888)
```

### Key Components

**Transport Layer** (`lib/core/network/aegis/transport/`)
- `_connection.dart` - Abstract interface for platform-agnostic connection
- `_native.dart` - Native TCP socket (Android/iOS/Desktop)
- `_web.dart` - WebSocket bridge (Browser)
- `_shared.dart` - Conditional compilation using Dart's `if (dart.library.html)`

**Server Infrastructure**
- **nginx** - Main web server (HTTPS termination, WebSocket proxy)
- **Node.js WebSocket Proxy** - Bridges browser WebSocket to native TCP
- **Aegis Server** - Native TCP messaging server

## 📝 Documentation Standards

Documents in this wiki are formatted for easy import into Docusaurus:

- **Markdown format** - Standard GitHub Flavored Markdown
- **Code blocks** - Language specified for syntax highlighting
- **Links** - Relative paths between wiki files
- **Headers** - H2 and below (H1 auto-generated)
- **Images** - Relative paths to assets folder

To export to Docusaurus:
1. Copy `.md` files from `wiki/` to Docusaurus `docs/` folder
2. Update relative links if needed
3. Add metadata to `sidebar.js`

## 🔗 Related Documentation

- [Project Status](./web-deployment.md#status) - Current deployment status
- [AGENTS.md](../AGENTS.md) - AI development guidelines
- [README.md](../README.md) - Main project readme
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Development setup guide

## ✅ Deployment Checklist

Before deploying to production:

- [ ] `flutter analyze` passes with no errors
- [ ] `flutter build web --release` completes successfully
- [ ] HTTPS certificates are valid and renewed
- [ ] WebSocket proxy is running: `systemctl status twospace-ws-proxy`
- [ ] nginx configuration is correct: `nginx -t`
- [ ] Server logs are being monitored
- [ ] Database migrations are applied
- [ ] API keys and secrets are configured
- [ ] CDN cache is invalidated (if using CDN)

## 🐛 Troubleshooting

### Common Issues

**White page in browser**
- Check DevTools console (F12) for JavaScript errors
- Check nginx error log: `tail -f /var/log/nginx/error.log`
- Check WebSocket proxy logs: `journalctl -u twospace-ws-proxy -f`

**Cannot connect to server**
- Verify WebSocket proxy is running: `systemctl status twospace-ws-proxy`
- Check TCP connection works: `curl -v http://localhost:9999/`
- Verify nginx upstream: `curl -v http://localhost:9999/`

**HTTPS not working**
- Verify certificate: `certbot certificates`
- Check nginx config: `nginx -t`
- Reload nginx: `systemctl reload nginx`

See [Deployment Guide](../web-deployment.md#troubleshooting) for more details.

## 📞 Support

For questions or issues:
1. Check [Deployment Guide](../web-deployment.md) troubleshooting section
2. Review [WebSocket Architecture](./architecture/websocket-architecture.md) documentation
3. Check server logs for error details
4. Refer to [AGENTS.md](../AGENTS.md) for development guidelines

---

**Last Updated**: 2026-04-21  
**Version**: 1.0  
**Status**: Production Ready
