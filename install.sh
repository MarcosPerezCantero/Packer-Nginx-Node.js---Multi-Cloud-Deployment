#!/bin/bash
set -e

# Wait for apt to be available
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  sleep 5
done

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Create Node.js application
sudo mkdir -p /opt/app
cat << 'EOF' | sudo tee /opt/app/app.js
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello from Node.js on Packer!');
});
server.listen(3000, '127.0.0.1', () => {
  console.log('Server running on port 3000');
});
EOF

# Configure PM2 to start the app
sudo chown -R ubuntu:ubuntu /opt/app
sudo -u ubuntu pm2 start /opt/app/app.js --name "app"
sudo -u ubuntu pm2 save
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu

# Install and configure Nginx
sudo apt install -y nginx

# Configure Nginx as reverse proxy
cat << 'EOF' | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
