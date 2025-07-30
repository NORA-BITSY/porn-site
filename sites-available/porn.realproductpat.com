# Virtual host configuration for porn.realproductpat.com
# This configuration handles both HTTP (for initial setup) and HTTPS

# Redirect HTTP to HTTPS (will be enabled after SSL cert is obtained)
server {
    listen 80;
    listen [::]:80;
    server_name porn.realproductpat.com www.porn.realproductpat.com;

    # Allow Let's Encrypt challenges
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        allow all;
    }

    # Redirect all other requests to HTTPS (uncomment after SSL setup)
    # return 301 https://$server_name$request_uri;

    # Temporary location for initial setup (remove after SSL is working)
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}

# HTTPS configuration (will be enabled after SSL cert is obtained)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name porn.realproductpat.com www.porn.realproductpat.com;

    # SSL certificate paths (will be configured by Certbot)
    ssl_certificate /etc/letsencrypt/live/porn.realproductpat.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/porn.realproductpat.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Rate limiting
    limit_req zone=general burst=10 nodelay;

    # Client max body size for uploads
    client_max_body_size 10M;

    # Serve static files directly
    location /css/ {
        alias /var/www/porn-site/public/css/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /js/ {
        alias /var/www/porn-site/public/js/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /images/ {
        alias /var/www/porn-site/public/images/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /videos/ {
        alias /var/www/porn-site/public/videos/;
        expires 1d;
        add_header Cache-Control "public";
    }

    # API rate limiting
    location /action/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }

    # Main application
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;

        # Optional: Add basic auth for additional security
        # auth_basic "Restricted Content";
        # auth_basic_user_file /etc/nginx/.htpasswd;
    }

    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /var/www/html;
    }
}
