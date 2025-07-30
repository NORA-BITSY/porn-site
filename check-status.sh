#!/bin/bash

# Server Status Check Script
# Verifies current server configuration and readiness for SSL setup

echo "🔍 Checking server status for porn.realproductpat.com..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to check command existence
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✅ $1 is installed${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    fi
}

# Function to check service status
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}✅ $1 service is running${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 service is not running${NC}"
        return 1
    fi
}

# Function to check port
check_port() {
    if netstat -tlnp 2>/dev/null | grep -q ":$1 "; then
        echo -e "${GREEN}✅ Port $1 is listening${NC}"
        return 0
    else
        echo -e "${RED}❌ Port $1 is not listening${NC}"
        return 1
    fi
}

echo -e "${YELLOW}📦 Checking installed packages...${NC}"
check_command nginx
check_command node
check_command npm
check_command certbot
check_command curl

echo ""
echo -e "${YELLOW}🔧 Checking services...${NC}"
check_service nginx
if systemctl list-unit-files | grep -q porn-site.service; then
    check_service porn-site
else
    echo -e "${YELLOW}⚠️  porn-site service not yet configured${NC}"
fi

echo ""
echo -e "${YELLOW}🌐 Checking network...${NC}"
check_port 80
check_port 443
if check_port 3000; then
    echo -e "${GREEN}  Node.js app is running on port 3000${NC}"
fi

echo ""
echo -e "${YELLOW}📁 Checking directories and files...${NC}"

# Check if we're in the right directory
if [ -f "server.js" ]; then
    echo -e "${GREEN}✅ Found server.js in current directory${NC}"
else
    echo -e "${RED}❌ server.js not found - make sure you're in /var/www/porn-site${NC}"
fi

# Check Node.js dependencies
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✅ Node.js dependencies installed${NC}"
else
    echo -e "${YELLOW}⚠️  Node.js dependencies not installed (run: npm install)${NC}"
fi

# Check if .env file exists
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ Environment file (.env) exists${NC}"
else
    echo -e "${YELLOW}⚠️  No .env file found (copy from .env.example)${NC}"
fi

echo ""
echo -e "${YELLOW}🌍 Checking domain resolution...${NC}"
if command -v dig &> /dev/null; then
    DIG_RESULT=$(dig +short porn.realproductpat.com)
    if [ -n "$DIG_RESULT" ]; then
        echo -e "${GREEN}✅ Domain resolves to: $DIG_RESULT${NC}"
    else
        echo -e "${RED}❌ Domain does not resolve${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  dig command not available (install dnsutils)${NC}"
fi

echo ""
echo -e "${YELLOW}🔐 Checking SSL certificates...${NC}"
if [ -d "/etc/letsencrypt/live/porn.realproductpat.com" ]; then
    echo -e "${GREEN}✅ SSL certificates found${NC}"
    certbot certificates 2>/dev/null | grep -A 5 "porn.realproductpat.com" || echo "Certificate details unavailable"
else
    echo -e "${YELLOW}⚠️  SSL certificates not yet obtained${NC}"
fi

echo ""
echo -e "${YELLOW}📊 Current status summary:${NC}"

# Test HTTP response if possible
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✅ Node.js application is responding${NC}"
else
    echo -e "${RED}❌ Node.js application is not responding${NC}"
fi

# Check if Nginx is serving the site
if curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✅ Nginx is serving content${NC}"
else
    echo -e "${YELLOW}⚠️  Nginx may not be properly configured${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. If not done yet: sudo ./setup-ssl.sh"
echo "2. Configure domain DNS to point to this server"
echo "3. Ensure firewall allows ports 80 and 443"
echo "4. Test the site: https://porn.realproductpat.com"

echo ""
echo -e "${GREEN}🎯 Quick commands:${NC}"
echo "• Start Node.js app: npm start"
echo "• Check app logs: journalctl -u porn-site -f"
echo "• Test Nginx: nginx -t"
echo "• Get SSL cert: sudo certbot certonly --webroot ..."
