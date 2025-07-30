#!/bin/bash

# SSL Setup Script for porn.realproductpat.com
# This script sets up Nginx with SSL using Let's Encrypt

set -e

echo "🔧 Setting up SSL for porn.realproductpat.com..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Domain configuration
DOMAIN="porn.realproductpat.com"
EMAIL="admin@realproductpat.com"  # Change this to your email
WEBROOT="/var/www/html"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

echo -e "${YELLOW}📦 Installing required packages...${NC}"

# Update package list
apt update

# Install Nginx if not already installed
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt install -y nginx
fi

# Install Certbot if not already installed
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    apt install -y certbot python3-certbot-nginx
fi

# Install Node.js and npm if not already installed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
fi

echo -e "${YELLOW}⚙️  Configuring Nginx...${NC}"

# Create webroot directory for Let's Encrypt challenges
mkdir -p $WEBROOT

# Copy our Nginx configuration
cp /var/www/porn-site/sites-available/porn.realproductpat.com /etc/nginx/sites-available/

# Enable the site
ln -sf /etc/nginx/sites-available/porn.realproductpat.com /etc/nginx/sites-enabled/

# Remove default site if it exists
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

# Test Nginx configuration
echo "Testing Nginx configuration..."
nginx -t

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Nginx configuration test failed!${NC}"
    exit 1
fi

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

echo -e "${YELLOW}🔑 Obtaining SSL certificate...${NC}"

# Obtain SSL certificate
certbot certonly \
    --webroot \
    --webroot-path=$WEBROOT \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --domains $DOMAIN,www.$DOMAIN

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ SSL certificate obtained successfully!${NC}"
    
    # Now update the Nginx configuration to enable HTTPS redirect
    echo -e "${YELLOW}🔄 Updating Nginx configuration for HTTPS...${NC}"
    
    # Uncomment the HTTPS redirect line
    sed -i 's/# return 301 https:\/\/\$server_name\$request_uri;/return 301 https:\/\/$server_name$request_uri;/' /etc/nginx/sites-available/porn.realproductpat.com
    
    # Comment out the temporary HTTP location block
    sed -i '/# Temporary location for initial setup/,/}/ s/^/# /' /etc/nginx/sites-available/porn.realproductpat.com
    
    # Test and reload Nginx
    nginx -t && systemctl reload nginx
    
    echo -e "${GREEN}🎉 SSL setup completed successfully!${NC}"
    echo -e "${GREEN}Your site is now available at: https://$DOMAIN${NC}"
else
    echo -e "${RED}❌ Failed to obtain SSL certificate!${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo "1. Domain DNS is pointing to this server"
    echo "2. Port 80 is accessible from the internet"
    echo "3. No firewall is blocking the connection"
    exit 1
fi

# Set up automatic renewal
echo -e "${YELLOW}⏰ Setting up automatic SSL renewal...${NC}"

# Add crontab entry for automatic renewal
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

echo -e "${GREEN}✅ Automatic SSL renewal configured!${NC}"

# Start the Node.js application if not already running
echo -e "${YELLOW}🚀 Starting Node.js application...${NC}"

cd /var/www/porn-site

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing Node.js dependencies..."
    npm install
fi

# Create a systemd service for the application
cat > /etc/systemd/system/porn-site.service << EOF
[Unit]
Description=Porn Site Node.js Application
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/porn-site
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable porn-site
systemctl start porn-site

echo -e "${GREEN}🎊 Setup completed successfully!${NC}"
echo -e "${GREEN}Your porn site is now running with SSL at: https://$DOMAIN${NC}"
echo ""
echo -e "${YELLOW}📋 Summary:${NC}"
echo "- Nginx is configured and running"
echo "- SSL certificate is installed and auto-renewal is set up"
echo "- Node.js application is running as a systemd service"
echo "- Site is accessible at https://$DOMAIN"
echo ""
echo -e "${YELLOW}🔧 Useful commands:${NC}"
echo "- Check application status: systemctl status porn-site"
echo "- View application logs: journalctl -u porn-site -f"
echo "- Check SSL certificate: certbot certificates"
echo "- Renew SSL manually: certbot renew"
echo "- Test Nginx config: nginx -t"
echo "- Reload Nginx: systemctl reload nginx"
