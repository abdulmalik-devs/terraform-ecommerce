#!/bin/bash
echo "*****************************************************************"
echo "Performing the following actions on Client-Admin Instance in AZ1"
echo "*****************************************************************"

sudo apt-get update
sudo apt-get install git -y

echo "---------------------------------------------"
echo "--INSTALL NVM TO USE A SPECIFIC NODE VERSION--"
echo "----------------------------------------------"
sudo apt-get install curl
sudo curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 18
sudo apt-get install npm -y
nvm alias default 18
npm -v
node -v

echo "-----PM2------"
sudo npm install -g pm2
sudo pm2 startup systemd

echo "-----NGINX------"
sudo apt-get install -y nginx

echo "---FIREWALL---"
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable 

echo "******************************************"
echo "Performing the following actions for Client"
echo "******************************************"

cd
sudo rm -rf full-ecommerce || true
sudo git clone https://github.com/abdulmalik-devs/mern-ecommerce-project.git
cd mern-ecommerce-project/
cd web_panel
sudo rm -rf build
npm install
npm run build
sudo pm2 delete react-build || true

# Create a new Nginx site configuration file
sudo tee /etc/nginx/sites-available/myapp.conf > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name _;  # Replace with your actual domain or IP address

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /admin {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Remove the default Nginx site configuration file
sudo rm -f /etc/nginx/sites-enabled/default

# Create a symbolic link to enable the new site configuration
sudo ln -s /etc/nginx/sites-available/myapp.conf /etc/nginx/sites-enabled/

# Test the Nginx configuration for any syntax errors
sudo nginx -t

# Restart Nginx to apply the new configuration
sudo systemctl restart nginx

pm2 serve build/ 3000 -f --name "client-server" --spa


echo "******************************************"
echo "Performing the following actions for Admin"
echo "******************************************"

cd /home/ubuntu
cd mern-ecommerce-project/
cd web_admin
sudo rm -rf build
npm install
npm run build
sudo pm2 delete react-admin || true
sudo pm2 serve build/ 3001 -f --name "admin-server" --spa


echo "******************************************"
echo "-----Client-Admin run Successfully--------"
echo "******************************************"