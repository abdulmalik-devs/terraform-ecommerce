#!/bin/bash

echo "----------------------------------------------------------"
echo "Performing the following actions on Client-Admin Instance"
echo "----------------------------------------------------------"

sudo apt-get update
sudo apt-get install git -y
sudo apt-get install curl -y

echo "-----NPM------"
sudo curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 18 -y
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

echo "--------------------------------------------"
echo "Performing the following actions for Client"
echo "--------------------------------------------"

cd ./application/client
echo "REACT_APP_API_BASEURL=http://${{ env.SERVER_IP }}" | sudo tee .env > /dev/null
sudo npm install

echo "---------Nginx Configration---------------"

sudo tee /etc/nginx/sites-available/myapp.conf > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name _;  

    location / {
        proxy_pass http://localhost:3000/;
    }

    location /admin/ {
        proxy_pass http://localhost:3001/;
    }
}
EOF

sudo rm -r /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/myapp.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

echo "-------Starting the client----------"
npm run build
pm2 serve build/ 3000 --name "client"

echo "-------------------------------------------"
echo "Performing the following actions for Admin"
echo "-------------------------------------------"
cd /home/ubuntu
cd ./application/admin
echo "REACT_APP_API_BASEURL=http://${{ env.SERVER_IP }}" | sudo tee .env > /dev/null
npm install
npm run build
sudo pm2 serve build/ 3001 --name "admin-server"

echo "------------------------------------------"
echo "-----Script Completed Successfully--------"
echo "------------------------------------------"