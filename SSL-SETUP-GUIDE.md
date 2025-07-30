# SSL and Nginx Setup Guide for porn.realproductpat.com

This guide provides complete instructions for setting up your porn site with Nginx, SSL certificates, and secure hosting.

## 🚀 Quick Setup

### Prerequisites
- Ubuntu/Debian server with root access
- Domain `porn.realproductpat.com` pointing to your server's IP
- Ports 80 and 443 open in firewall

### One-Command Setup
```bash
sudo ./setup-ssl.sh
```

## 📋 Manual Setup Steps

### 1. Install Dependencies
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install -y nginx

# Install Certbot for Let's Encrypt
sudo apt install -y certbot python3-certbot-nginx

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### 2. Configure Nginx
```bash
# Copy site configuration
sudo cp sites-available/porn.realproductpat.com /etc/nginx/sites-available/

# Enable the site
sudo ln -s /etc/nginx/sites-available/porn.realproductpat.com /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### 3. Obtain SSL Certificate
```bash
# Create webroot for challenges
sudo mkdir -p /var/www/html

# Get certificate
sudo certbot certonly \
    --webroot \
    --webroot-path=/var/www/html \
    --email admin@realproductpat.com \
    --agree-tos \
    --no-eff-email \
    --domains porn.realproductpat.com,www.porn.realproductpat.com
```

### 4. Enable HTTPS Redirect
After obtaining the certificate, edit `/etc/nginx/sites-available/porn.realproductpat.com`:
- Uncomment the HTTPS redirect line
- Comment out the temporary HTTP location block
- Reload Nginx: `sudo systemctl reload nginx`

### 5. Setup Application Service
```bash
# Install dependencies
cd /var/www/porn-site
npm install

# Create systemd service
sudo cp porn-site.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable porn-site
sudo systemctl start porn-site
```

## 🔧 Configuration Files

### Nginx Main Config: `nginx.conf`
- Security headers
- SSL optimization
- Rate limiting
- Gzip compression

### Site Config: `sites-available/porn.realproductpat.com`
- HTTP to HTTPS redirect
- SSL certificate paths
- Reverse proxy to Node.js app
- Static file serving
- Security headers

### Environment: `.env.example`
Copy to `.env` and customize:
```bash
cp .env.example .env
nano .env
```

## 🛡️ Security Features

### SSL/TLS
- TLS 1.2 and 1.3 only
- Strong cipher suites
- HSTS headers
- SSL stapling

### Rate Limiting
- General: 5 requests/second
- API: 10 requests/second
- Burst handling

### Headers
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- X-XSS-Protection: enabled
- Referrer-Policy: strict-origin-when-cross-origin

## 🔄 Maintenance

### SSL Certificate Renewal
Automatic renewal is set up via cron. Manual renewal:
```bash
sudo ./renew-ssl.sh
```

### Check Status
```bash
# Application status
sudo systemctl status porn-site

# View logs
sudo journalctl -u porn-site -f

# Check SSL certificates
sudo certbot certificates

# Test Nginx config
sudo nginx -t
```

### Backup Commands
```bash
# Backup SSL certificates
sudo tar -czf ssl-backup-$(date +%Y%m%d).tar.gz /etc/letsencrypt/

# Backup Nginx config
sudo tar -czf nginx-backup-$(date +%Y%m%d).tar.gz /etc/nginx/
```

## 🌐 Access Your Site

After setup completion:
- **HTTP**: http://porn.realproductpat.com (redirects to HTTPS)
- **HTTPS**: https://porn.realproductpat.com (main site)

## 🔍 Troubleshooting

### Common Issues

1. **Certificate not obtained**
   - Check domain DNS points to server
   - Verify port 80 is accessible
   - Check firewall settings

2. **Application not starting**
   - Check Node.js dependencies: `npm install`
   - Verify MongoDB is running
   - Check environment variables

3. **Nginx errors**
   - Test config: `nginx -t`
   - Check logs: `/var/log/nginx/error.log`
   - Verify file permissions

### Useful Commands
```bash
# Check what's running on port 80/443
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Test SSL certificate
openssl s_client -connect porn.realproductpat.com:443

# Check domain resolution
nslookup porn.realproductpat.com

# Test HTTP response
curl -I http://porn.realproductpat.com
curl -I https://porn.realproductpat.com
```

## 📞 Support

If you encounter issues:
1. Check the logs first
2. Verify all prerequisites are met
3. Ensure domain DNS is properly configured
4. Check firewall and security groups

## 🔐 Security Recommendations

1. **Firewall**: Only open ports 22, 80, 443
2. **SSH**: Use key-based authentication
3. **Updates**: Keep system and packages updated
4. **Monitoring**: Set up log monitoring
5. **Backup**: Regular backups of data and configs

---

## 📝 Notes

- The application runs on port 3000 internally
- Nginx proxies requests to the Node.js app
- SSL certificates auto-renew every 60 days
- Static files are served directly by Nginx for performance
