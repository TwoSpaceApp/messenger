# TwoSpace Web Platform - WebSocket Architecture Implementation

## Overview

This document describes the complete architecture for supporting the TwoSpace Messenger on web platforms with full Aegis protocol communication via WebSocket bridge.

## Problem Statement

The original Flutter application used native TCP sockets (dart:io) for Aegis protocol communication. Web browsers cannot use raw TCP connections - they only support HTTP/HTTPS and WebSocket protocols. This required a complete architectural redesign to:

1. Isolate platform-specific code
2. Support both native (TCP) and web (WebSocket) connections
3. Maintain single codebase with platform-specific conditional compilation
4. Ensure graceful error handling for unimplemented features

## Solution Architecture

### 1. **Transport Layer Abstraction** 

Located in: `/lib/core/network/aegis/transport/`

#### Structure:
```
transport/
├── _connection.dart      # Abstract interface (AegisConnection)
├── _native.dart          # Native TCP implementation
├── _web.dart             # Web WebSocket implementation (stub)
└── _shared.dart          # Conditional export factory
```

#### Key Components:

**_connection.dart** - Abstract Interface
```dart
abstract class AegisConnection {
  bool get isConnected;
  Stream<Uint8List> get onData;
  Stream<Object> get onError;
  Stream<void> get onClose;
  
  Future<void> connect(String host, int port, {Duration? timeout, bool useTls});
  Future<void> send(Uint8List data);
  Future<void> flush();
  void pause();
  void resume();
  Future<void> close();
  void dispose();
}
```

**_native.dart** - Native Implementation (Mobile/Desktop/Linux)
- Uses `dart:io.Socket` and `dart:io.SecureSocket`
- Direct TCP connection to localhost:8888
- Provides `NativeAegisConnection` class
- Implements full bidirectional communication

**_web.dart** - Web Implementation (Browser)
- Implements `WebAegisConnection` class
- Currently returns `UnsupportedError` with graceful message
- Prepared for future dart:html WebSocket integration
- **Note**: Requires server-side WebSocket proxy to function

**_shared.dart** - Conditional Export (Dart Compilation Magic)
```dart
import '_native.dart' if (dart.library.html) '_web.dart' as impl;

// Exported factory function - chooses implementation at compile time
AegisConnection createConnection() {
  return impl.createConnection();
}
```

The `if (dart.library.html)` directive is Dart's compile-time conditional:
- **Non-web platforms**: Compiles `_native.dart` (has dart:io)
- **Web platforms**: Compiles `_web.dart` (HTML/WebSocket safe)

### 2. **Server-Side WebSocket Proxy**

Located at: `/opt/websocket-proxy/` on server

#### Implementation: Node.js with `ws` library

**File**: `websocket-proxy.js`

**Functionality**:
1. Listens on port 9999 for WebSocket connections
2. For each WebSocket client:
   - Opens TCP connection to localhost:8888 (native Aegis server)
   - Bridges data bidirectionally:
     - TCP → WebSocket: Raw bytes from Aegis server
     - WebSocket → TCP: Raw bytes from browser client
3. Handles connection lifecycle, errors, and graceful shutdown
4. Implements ping/pong keep-alive (30 second interval)

**Key Features**:
```javascript
// TCP ← → WebSocket bridge
tcpSocket.on('data', (data) => {
  ws.send(data); // TCP data to browser
});

ws.on('message', (data) => {
  tcpSocket.write(data); // Browser data to TCP
});
```

### 3. **nginx Reverse Proxy Configuration**

Located at: `/etc/nginx/sites-available/web.twospace.ru`

**WebSocket Support**:
```nginx
location /ws {
    proxy_pass http://websocket_backend;  # Forward to Node.js proxy
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_buffering off;  # Critical for WebSocket
}
```

**Upstream Definition**:
```nginx
upstream websocket_backend {
    server localhost:9999;
}
```

### 4. **systemd Service Configuration**

Located at: `/etc/systemd/system/twospace-ws-proxy.service`

**Purpose**: Auto-start and manage WebSocket proxy service

**Key Settings**:
- Auto-restart on failure
- Resource limits (65536 file descriptors)
- Logging to journald
- User: root
- Working directory: /opt/websocket-proxy

## Deployment Flow

### Client (Flutter Web Build)
1. `flutter build web --release`
2. Dart compiler processes `if (dart.library.html)` directive
3. Compiles `_web.dart` for web output
4. `WebAegisConnection` gets bundled into main.dart.js
5. Browser loads Flutter app from https://web.twospace.ru

### Server Infrastructure
```
Browser (HTTPS/WebSocket) 
    ↓
nginx (port 443) 
    ↓ (location /ws)
Node.js Proxy (port 9999)
    ↓ (TCP connection)
Aegis Server (localhost:8888)
```

### Connection Attempt
1. App connects via `AegisAuthService`
2. Transport layer calls `createConnection()`
3. On web: Returns `WebAegisConnection` (stub with error)
4. On native: Returns `NativeAegisConnection` (full TCP)

## Current Status

### ✅ Completed
- Transport abstraction layer implemented
- Conditional compilation working (verified with `flutter analyze`)
- Web build successful (43MB, 63 files)
- WebSocket proxy deployed and running
- nginx configured with WebSocket support
- HTTPS certificates configured (valid until 2026-07-19)
- systemd service managing proxy lifecycle

### ⏳ Not Yet Implemented
- Full dart:html WebSocket client in `_web.dart`
- Browser-side WebSocket connection
- Runtime testing of web connectivity

## Testing Checklist

1. **Build Verification**
   ```bash
   flutter analyze lib/core/network/aegis/transport*
   # Expected: No issues found
   
   flutter build web --release
   # Expected: ✓ Built build/web
   ```

2. **Server Status**
   ```bash
   systemctl status nginx twospace-ws-proxy
   # Expected: Both active (running)
   
   ss -tlnp | grep 9999
   # Expected: Node listening on port 9999
   ```

3. **Web Access**
   - Open https://web.twospace.ru in browser
   - Check browser console for WebSocket errors
   - Expected: App loads, attempts connection, shows graceful error

## Future Enhancements

### 1. **Full WebSocket Implementation**
Replace stub in `_web.dart` with complete implementation:
```dart
class WebAegisConnection implements AegisConnection {
  late dynamic _ws;  // dart:html WebSocket
  
  Future<void> connect(...) async {
    // Use dart:html.WebSocket
    _ws = WebSocket('wss://95.215.56.43/ws');
    _ws.onMessage.listen((event) {
      _dataController.add(event.data);
    });
  }
}
```

### 2. **Certificate Management**
- Auto-renewal via certbot
- Monitor SSL validity
- Alert on certificate expiration (2026-07-19)

### 3. **Performance Optimization**
- Message batching in WebSocket proxy
- Compression support
- Connection pooling

## File Locations Summary

| Component | Path | Language |
|-----------|------|----------|
| Transport Abstract | `/lib/core/network/aegis/transport/_connection.dart` | Dart |
| Transport Native | `/lib/core/network/aegis/transport/_native.dart` | Dart |
| Transport Web | `/lib/core/network/aegis/transport/_web.dart` | Dart |
| Transport Shared | `/lib/core/network/aegis/transport/_shared.dart` | Dart |
| Main Transport | `/lib/core/network/aegis/transport.dart` | Dart |
| WebSocket Proxy | `/opt/websocket-proxy/websocket-proxy.js` | Node.js |
| nginx Config | `/etc/nginx/sites-available/web.twospace.ru` | nginx |
| systemd Service | `/etc/systemd/system/twospace-ws-proxy.service` | ini |

## Troubleshooting

### Issue: "Failed to connect to 95.215.56.43:8888"
**Cause**: WebSocket implementation in `_web.dart` not yet complete  
**Solution**: This is expected. Stub throws UnsupportedError with helpful message.

### Issue: WebSocket proxy not starting
**Solution**:
```bash
systemctl start twospace-ws-proxy
journalctl -u twospace-ws-proxy -n 50 --no-pager
```

### Issue: HTTPS not working
**Solution**:
```bash
certbot renew --dry-run  # Test renewal
systemctl reload nginx
```

## References

- **Dart Conditional Imports**: https://dart.dev/guides/libraries/create-library-packages#conditional-imports
- **Aegis Protocol**: See `/lib/core/network/aegis/` documentation
- **Node.js WebSocket**: https://github.com/websockets/ws
- **nginx WebSocket Proxying**: http://nginx.org/en/docs/http/websocket.html

## Deployment Checklist

- [x] Transport abstraction created
- [x] Platform-specific implementations
- [x] WebSocket proxy deployed
- [x] nginx configured
- [x] HTTPS certificates active
- [x] systemd service running
- [x] Web build deployed
- [ ] End-to-end testing
- [ ] Performance monitoring
- [ ] User documentation

---

**Last Updated**: 2026-04-20  
**Version**: 1.0  
**Status**: Architecture Complete, WebSocket Client Pending
