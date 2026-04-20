#!/bin/bash
#
# Server setup script for TwoSpace Web deployment
# Run this on the production server after deployment
# Usage: sudo bash setup-server.sh
#

set -e

DOMAIN="web.twospace.ru"
APP_DIR="/var/www/twospace-web"

echo "🔧 Setting up TwoSpace Web server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Domain: $DOMAIN"
echo "App directory: $APP_DIR"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root (sudo)"
  exit 1
fi

# Step 1: Update system
echo "📦 Step 1/6: Updating system packages..."
apt-get update
apt-get upgrade -y

# Step 2: Install nginx
echo "🌐 Step 2/6: Installing Nginx..."
if ! command -v nginx &> /dev/null; then
  apt-get install -y nginx
else
  echo "   Nginx already installed"
fi

# Step 3: Install certbot
echo "🔐 Step 3/6: Installing Certbot for SSL..."
if ! command -v certbot &> /dev/null; then
  apt-get install -y certbot python3-certbot-nginx
else
  echo "   Certbot already installed"
fi

# Step 4: Configure nginx
echo "🎯 Step 4/6: Configuring Nginx..."
if [ ! -f "/opt/twospace/nginx.conf" ]; then
  echo "   ⚠️  nginx.conf not found at /opt/twospace/nginx.conf"
  echo "   Please copy it from the deployment package first:"
  echo "   scp scripts/nginx.conf root@$DOMAIN:/opt/twospace/"
else
  cp "/opt/twospace/nginx.conf" "/etc/nginx/sites-available/twospace"
  # Remove default site
  rm -f /etc/nginx/sites-enabled/default
  # Enable twospace site
  ln -sf /etc/nginx/sites-available/twospace /etc/nginx/sites-enabled/
  echo "   ✓ Nginx configuration installed"
fi

# Test nginx configuration
echo "   Testing nginx configuration..."
nginx -t
echo "   ✓ Configuration is valid"

# Step 5: Create certbot webroot
echo "📁 Step 5/6: Creating Certbot webroot..."
mkdir -p /var/www/certbot
chown -R www-data:www-data /var/www/certbot

# Step 6: Generate SSL certificates
echo "🔐 Step 6/6: Generating SSL certificates..."
echo ""
echo "   You will be prompted to enter your email for certificate notifications"
echo "   Press Enter if already configured, or enter your email:"
echo ""

# Try to obtain certificate
certbot certonly --nginx -d "$DOMAIN" --agree-tos --no-eff-email || {
  echo "   ⚠️  Certificate generation failed."
  echo "   Make sure:"
  echo "   - Domain points to this server"
  echo "   - Port 80 is accessible"
  echo "   - Nginx is running"
  echo ""
  echo "   Manual retry:"
  echo "   sudo certbot certonly --nginx -d $DOMAIN"
}

# Reload nginx with SSL
echo ""
echo "🔄 Reloading Nginx with SSL configuration..."
systemctl reload nginx

# Setup auto-renewal
echo "⏰ Setting up certificate auto-renewal..."
systemctl enable certbot.timer
systemctl start certbot.timer

echo ""
echo "✅ Server setup complete!"
echo ""
echo "📊 Server status:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
systemctl status nginx --no-pager || true
echo ""

echo "🧪 Verification:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Check site: https://${DOMAIN}/"
echo "   SSL test: https://www.ssllabs.com/ssltest/analyze.html?d=${DOMAIN}"
echo ""

echo "📝 Useful commands:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   View logs:      journalctl -u nginx -f"
echo "   Test config:    nginx -t"
echo "   Reload:         systemctl reload nginx"
echo "   Restart:        systemctl restart nginx"
echo "   SSL status:     certbot renew --dry-run"
echo "   SSL renewal:    sudo certbot renew --force-renewal"
echo ""
