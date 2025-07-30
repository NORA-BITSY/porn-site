#!/bin/bash

# Quick SSL Certificate Renewal Script
# Run this script to manually renew SSL certificates

set -e

echo "🔄 Renewing SSL certificates..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

echo -e "${YELLOW}Checking certificate expiration...${NC}"
certbot certificates

echo -e "${YELLOW}Attempting to renew certificates...${NC}"
certbot renew --dry-run

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dry run successful! Proceeding with actual renewal...${NC}"
    certbot renew
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Certificates renewed successfully!${NC}"
        echo -e "${YELLOW}Reloading Nginx...${NC}"
        systemctl reload nginx
        echo -e "${GREEN}🎉 SSL renewal completed!${NC}"
    else
        echo -e "${RED}❌ Certificate renewal failed!${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Dry run failed! Please check the configuration.${NC}"
    exit 1
fi
