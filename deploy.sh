#!/bin/bash

# Deploy script for Flutter web application to web.twospace.ru
# Usage: ./deploy.sh

set -e

# Configuration
SERVER_IP="95.215.56.43"
SERVER_USER="root"
DOMAIN="web.twospace.ru"
REMOTE_PATH="/var/www/web.twospace.ru"
LOCAL_BUILD_DIR="build/web"
TEMP_DIR="/tmp/flutter_web_build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Flutter Web Deployment Script${NC}"
echo "=================================="
echo "Server: $SERVER_IP"
echo "Domain: $DOMAIN"
echo "=================================="

# Step 1: Build Flutter web
echo -e "${YELLOW}📦 Building Flutter web application...${NC}"
if ! flutter build web --release; then
    echo -e "${RED}❌ Flutter build failed!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Build completed${NC}"

# Step 2: Create temp directory and prepare build
echo -e "${YELLOW}📝 Preparing build directory...${NC}"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cp -r "$LOCAL_BUILD_DIR"/* "$TEMP_DIR/"
echo -e "${GREEN}✓ Build prepared${NC}"

# Step 3: Compress build
echo -e "${YELLOW}📦 Compressing build...${NC}"
cd "$TEMP_DIR"/..
tar -czf flutter_web_build.tar.gz flutter_web_build/
cd - > /dev/null
echo -e "${GREEN}✓ Build compressed${NC}"

# Step 4: Upload to server
echo -e "${YELLOW}📤 Uploading to server...${NC}"
if ! scp -o StrictHostKeyChecking=no "$TEMP_DIR/../flutter_web_build.tar.gz" "$SERVER_USER@$SERVER_IP:/tmp/"; then
    echo -e "${RED}❌ Upload failed!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Upload completed${NC}"

# Step 5: Extract and deploy on server
echo -e "${YELLOW}🔧 Deploying on server...${NC}"
ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" << DEPLOY_SCRIPT
    set -e
    echo "Extracting build..."
    cd /tmp
    tar -xzf flutter_web_build.tar.gz
    
    echo "Backup current build..."
    if [ -d "$REMOTE_PATH/build_backup" ]; then
        rm -rf "$REMOTE_PATH/build_backup"
    fi
    if [ -d "$REMOTE_PATH/index.html" ]; then
        mkdir -p "$REMOTE_PATH/build_backup"
        cp -r "$REMOTE_PATH"/* "$REMOTE_PATH/build_backup/" 2>/dev/null || true
    fi
    
    echo "Copying new build..."
    rm -rf "$REMOTE_PATH"/*
    cp -r flutter_web_build/* "$REMOTE_PATH/"
    
    echo "Setting permissions..."
    chown -R www-data:www-data "$REMOTE_PATH"
    chmod -R 755 "$REMOTE_PATH"
    
    echo "Reloading nginx..."
    systemctl reload nginx
    
    echo "Cleaning up..."
    rm -rf /tmp/flutter_web_build /tmp/flutter_web_build.tar.gz
    
    echo "✓ Deployment completed!"
DEPLOY_SCRIPT

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Deployment failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Deployment on server completed${NC}"

# Step 6: Cleanup local temp
rm -rf "$TEMP_DIR"
rm -f "$TEMP_DIR/../flutter_web_build.tar.gz"

echo ""
echo -e "${GREEN}✅ Deployment successful!${NC}"
echo "🌐 Your app is now available at: https://$DOMAIN"
echo ""
