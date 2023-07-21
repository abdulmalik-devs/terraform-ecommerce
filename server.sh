#!/bin/bash

echo "----------------------------------------------------"
echo "Performing the following actions on Server Instance"
echo "----------------------------------------------------"

sudo apt-get update
sudo apt-get install git -y
sudo apt-get install curl -y

echo "-----NPM------"

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
sudo npm install -g pm2 -y

echo "-----NGINX------"
sudo apt-get install -y nginx

echo "---FIREWALL---"
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable 


echo "---------Nginx Configration---------------"

cd ./application/server
sudo npm install
sudo tee /etc/nginx/sites-available/myapp.conf > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name _;  

    location / {
        proxy_pass http://localhost:5002/api/;
    }
}
EOF

sudo rm -r /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/myapp.conf /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx
echo "-------The configuration is completed successfully------"

echo "-------Starting the server----------"
sudo pm2 start index.js --name "backend-server"










