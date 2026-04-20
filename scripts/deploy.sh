#!/bin/bash
#
# Deployment script for TwoSpace Web to production server
# Usage: ./scripts/deploy.sh <server_ip> <username>
# Example: ./scripts/deploy.sh 95.215.56.43 root
#

set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <server_ip> <username>"
  echo "Example: $0 95.215.56.43 root"
  exit 1
fi

SERVER_IP="$1"
SERVER_USER="$2"
DOMAIN="web.twospace.ru"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build/web"
REMOTE_APP_DIR="/var/www/twospace-web"

echo "🚀 Deploying TwoSpace Web to production"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Server: $SERVER_IP"
echo "User: $SERVER_USER"
echo "Domain: $DOMAIN"
echo "App directory: $REMOTE_APP_DIR"
echo ""

# Check if build exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Build directory not found: $BUILD_DIR"
  echo "   Run: ./scripts/build-web.sh first"
  exit 1
fi

# Step 1: Build the web version
echo "📦 Step 1/4: Building web version..."
cd "$SCRIPT_DIR"
./scripts/build-web.sh --release

# Step 2: Prepare deployment
echo ""
echo "📋 Step 2/4: Preparing deployment package..."
DEPLOY_PACKAGE="/tmp/twospace-web-$(date +%s).tar.gz"
cd "$BUILD_DIR"
tar -czf "$DEPLOY_PACKAGE" .
echo "   Package: $DEPLOY_PACKAGE"
echo "   Size: $(du -h "$DEPLOY_PACKAGE" | cut -f1)"

# Step 3: Deploy to server
echo ""
echo "🌐 Step 3/4: Uploading to server..."
scp "$DEPLOY_PACKAGE" "${SERVER_USER}@${SERVER_IP}:/tmp/"
echo "   ✓ Upload complete"

# Step 4: Extract and restart on server
echo ""
echo "🔧 Step 4/4: Extracting and configuring on server..."

ssh "${SERVER_USER}@${SERVER_IP}" bash <<'REMOTE_SCRIPT'
set -e

REMOTE_APP_DIR="/var/www/twospace-web"
DEPLOY_PACKAGE=$(ls -t /tmp/twospace-web-*.tar.gz | head -1)

echo "   Stopping web service..."
sudo systemctl stop twospace-web || true

echo "   Creating backup..."
[ -d "$REMOTE_APP_DIR" ] && sudo mv "$REMOTE_APP_DIR" "${REMOTE_APP_DIR}.backup.$(date +%s)"

echo "   Creating app directory..."
sudo mkdir -p "$REMOTE_APP_DIR"

echo "   Extracting package..."
sudo tar -xzf "$DEPLOY_PACKAGE" -C "$REMOTE_APP_DIR"

echo "   Setting permissions..."
sudo chown -R www-data:www-data "$REMOTE_APP_DIR"
sudo chmod -R 755 "$REMOTE_APP_DIR"

echo "   Cleaning package..."
rm "$DEPLOY_PACKAGE"

echo "   ✓ Extraction complete"
REMOTE_SCRIPT

# Verify deployment
echo ""
echo "✅ Deployment complete!"
echo ""
echo "🔍 Next steps:"
echo "   1. SSH to server: ssh ${SERVER_USER}@${SERVER_IP}"
echo "   2. Run server setup: bash /opt/twospace/setup-server.sh"
echo "   3. Or manually:"
echo "      - Setup nginx: sudo cp /opt/twospace/nginx.conf /etc/nginx/sites-available/twospace"
echo "      - Enable site: sudo ln -sf /etc/nginx/sites-available/twospace /etc/nginx/sites-enabled/"
echo "      - Test nginx: sudo nginx -t"
echo "      - Reload: sudo systemctl reload nginx"
echo "      - Setup SSL: sudo certbot certonly --nginx -d web.twospace.ru"
echo "      - Auto-renewal: sudo systemctl enable certbot.timer"
echo ""
echo "📝 Logs and status:"
echo "   journalctl -u nginx -f"
echo "   curl -I http://${DOMAIN}/"
