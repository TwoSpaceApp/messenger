#!/bin/bash

# TwoSpace Web Quick Deploy Script
# Usage: ./scripts/deploy-web-quick.sh [server] [user]
# Example: ./scripts/deploy-web-quick.sh 95.215.56.43 root

set -e

# Configuration
SERVER="${1:-95.215.56.43}"
USER="${2:-root}"
DEPLOY_PATH="/var/www/web.twospace.ru"

echo "🚀 TwoSpace Web Quick Deploy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Server: $SERVER"
echo "User: $USER"
echo "Deploy path: $DEPLOY_PATH"
echo ""

# Step 1: Build
echo "📦 Step 1/3: Building Flutter web..."
if ! flutter build web --release; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✓ Build complete ($(du -sh build/web | cut -f1))"
echo ""

# Step 2: Deploy
echo "📤 Step 2/3: Deploying to server..."
if ! rsync -avz --delete build/web/ "$USER@$SERVER:$DEPLOY_PATH/"; then
    echo "❌ Deployment failed!"
    exit 1
fi
echo "✓ Deployment complete"
echo ""

# Step 3: Verify
echo "🔍 Step 3/3: Verifying deployment..."
if ssh "$USER@$SERVER" "curl -s -I https://web.twospace.ru/ | head -1" | grep -q "200"; then
    echo "✓ Site is accessible: https://web.twospace.ru"
else
    echo "⚠️ Warning: Site may not be fully accessible, check server logs"
fi
echo ""

echo "🎉 Deployment complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo "  1. Open: https://web.twospace.ru"
echo "  2. Check browser console (F12) for errors"
echo "  3. See wiki/web-deployment.md for troubleshooting"
