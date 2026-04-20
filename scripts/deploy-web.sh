#!/bin/bash

# Messenger Web Deployment Script
# Deploys the Flutter web build to a remote server

set -e

# Configuration
SERVER_IP="${1:-95.215.56.43}"
SERVER_USER="${2:-root}"
DOMAIN="${3:-web.twospace.ru}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build/web"
REMOTE_PATH="/var/www/$DOMAIN"
ENABLE_SSL="${4:-true}"

echo "========================================="
echo "Messenger Web Deployment Script"
echo "========================================="
echo "Server: $SERVER_IP"
echo "User: $SERVER_USER"
echo "Domain: $DOMAIN"
echo "Build Dir: $BUILD_DIR"
echo "Remote Path: $REMOTE_PATH"
echo "Enable SSL: $ENABLE_SSL"
echo "========================================="

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "ERROR: Build directory not found at $BUILD_DIR"
    echo "Please run: flutter build web --release"
    exit 1
fi

echo ""
echo "[1/4] Building web application..."
cd "$PROJECT_ROOT"
flutter build web --release

echo ""
echo "[2/4] Uploading files to server..."
rsync -avz --delete -e "ssh -o StrictHostKeyChecking=no" "$BUILD_DIR/" "$SERVER_USER@$SERVER_IP:$REMOTE_PATH/"

echo ""
echo "[3/4] Setting permissions on server..."
ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" "chmod -R 755 $REMOTE_PATH && chown -R www-data:www-data $REMOTE_PATH"

echo ""
echo "[4/4] Reloading nginx..."
ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" "nginx -t && systemctl reload nginx"

if [ "$ENABLE_SSL" = "true" ]; then
    echo ""
    echo "SSL Configuration (Run on server):"
    echo "  certbot --nginx -d $DOMAIN"
    echo ""
fi

echo ""
echo "========================================="
echo "✓ Deployment completed successfully!"
echo "========================================="
echo ""
echo "Access your app at: https://$DOMAIN"
echo ""

if [ "$ENABLE_SSL" != "true" ]; then
    echo "Note: SSL is not enabled. To enable it, run on the server:"
    echo "  sudo certbot --nginx -d $DOMAIN"
    echo ""
fi
