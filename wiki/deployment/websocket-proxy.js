#!/usr/bin/env node
/**
 * WebSocket to TCP Bridge for Aegis Protocol
 * 
 * This service acts as a bridge between WebSocket clients (browsers) 
 * and the native TCP Aegis server.
 * 
 * WebSocket client connects via: ws://95.215.56.43:8888/ws
 * This proxy forwards all messages to TCP localhost:8888
 */

const WebSocket = require('ws');
const net = require('net');
const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const WS_PORT = process.env.WS_PORT || 8888;
const TCP_HOST = process.env.TCP_HOST || 'localhost';
const TCP_PORT = process.env.TCP_PORT || 8888;
const USE_SSL = process.env.USE_SSL === 'true';
const CERT_PATH = process.env.CERT_PATH || '/etc/letsencrypt/live/web.twospace.ru/fullchain.pem';
const KEY_PATH = process.env.KEY_PATH || '/etc/letsencrypt/live/web.twospace.ru/privkey.pem';

console.log(`[WebSocket Proxy] Starting bridge...`);
console.log(`  WebSocket: ${USE_SSL ? 'wss' : 'ws'}://0.0.0.0:${WS_PORT}`);
console.log(`  TCP backend: tcp://${TCP_HOST}:${TCP_PORT}`);

// Create HTTP/HTTPS server for WebSocket
let server;
if (USE_SSL && fs.existsSync(CERT_PATH) && fs.existsSync(KEY_PATH)) {
  console.log('[WebSocket Proxy] Using SSL/TLS');
  const options = {
    cert: fs.readFileSync(CERT_PATH),
    key: fs.readFileSync(KEY_PATH),
  };
  server = https.createServer(options);
} else {
  console.log('[WebSocket Proxy] Using HTTP (SSL disabled or certs not found)');
  server = http.createServer();
}

// Create WebSocket server
const wss = new WebSocket.Server({ 
  server,
  perMessageDeflate: false, // Disable compression for binary protocol
  maxPayload: 256 * 1024, // 256KB max frame
});

let connectionCount = 0;

wss.on('connection', (ws, req) => {
  const clientId = ++connectionCount;
  const clientIp = req.socket.remoteAddress;
  
  console.log(`[Client ${clientId}] Connected from ${clientIp}`);

  // Create TCP connection to backend
  const tcpSocket = net.createConnection({ host: TCP_HOST, port: TCP_PORT });
  let tcpConnected = false;
  let wsConnected = true;

  tcpSocket.on('connect', () => {
    tcpConnected = true;
    console.log(`[Client ${clientId}] TCP connection established to ${TCP_HOST}:${TCP_PORT}`);
  });

  // Bridge: TCP -> WebSocket
  tcpSocket.on('data', (data) => {
    if (!wsConnected) {
      console.log(`[Client ${clientId}] Received TCP data but WS closed, discarding`);
      return;
    }
    try {
      ws.send(data, (err) => {
        if (err) {
          console.error(`[Client ${clientId}] Error sending to WebSocket:`, err.message);
          tcpSocket.destroy();
        }
      });
    } catch (err) {
      console.error(`[Client ${clientId}] Error in TCP->WS bridge:`, err.message);
      tcpSocket.destroy();
    }
  });

  tcpSocket.on('error', (err) => {
    console.error(`[Client ${clientId}] TCP error:`, err.message);
    wsConnected = false;
    if (ws.readyState === WebSocket.OPEN) {
      // Send error message to client
      try {
        ws.close(1011, `TCP connection error: ${err.message}`);
      } catch (e) {
        console.error(`[Client ${clientId}] Error closing WebSocket:`, e.message);
      }
    }
  });

  tcpSocket.on('close', () => {
    console.log(`[Client ${clientId}] TCP connection closed`);
    wsConnected = false;
    if (ws.readyState === WebSocket.OPEN) {
      ws.close(1000, 'TCP connection closed');
    }
  });

  // Bridge: WebSocket -> TCP
  ws.on('message', (data) => {
    if (!tcpConnected) {
      console.log(`[Client ${clientId}] Received WS message but TCP not connected`);
      return;
    }
    try {
      tcpSocket.write(data, (err) => {
        if (err) {
          console.error(`[Client ${clientId}] Error writing to TCP:`, err.message);
          ws.close(1011, 'TCP write error');
        }
      });
    } catch (err) {
      console.error(`[Client ${clientId}] Error in WS->TCP bridge:`, err.message);
      ws.close(1011, 'Bridge error');
    }
  });

  ws.on('error', (err) => {
    console.error(`[Client ${clientId}] WebSocket error:`, err.message);
    tcpSocket.destroy();
  });

  ws.on('close', (code, reason) => {
    console.log(`[Client ${clientId}] WebSocket closed (code: ${code}, reason: ${reason || 'none'})`);
    wsConnected = false;
    tcpSocket.destroy();
  });

  // Ping-pong to detect disconnects
  ws.isAlive = true;
  ws.on('pong', () => {
    ws.isAlive = true;
  });
});

// Periodic ping to detect dead connections
setInterval(() => {
  wss.clients.forEach((ws) => {
    if (ws.isAlive === false) {
      return ws.terminate();
    }
    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

server.listen(WS_PORT, '0.0.0.0', () => {
  console.log(`[WebSocket Proxy] ✓ Listening on port ${WS_PORT}`);
  console.log(`[WebSocket Proxy] Ready to proxy connections`);
});

server.on('error', (err) => {
  console.error('[WebSocket Proxy] Server error:', err.message);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('[WebSocket Proxy] SIGTERM received, shutting down...');
  wss.close(() => {
    server.close(() => {
      console.log('[WebSocket Proxy] ✓ Gracefully shut down');
      process.exit(0);
    });
  });
});

process.on('SIGINT', () => {
  console.log('[WebSocket Proxy] SIGINT received, shutting down...');
  wss.close(() => {
    server.close(() => {
      console.log('[WebSocket Proxy] ✓ Gracefully shut down');
      process.exit(0);
    });
  });
});

console.log('[WebSocket Proxy] Ready! Waiting for connections...');
