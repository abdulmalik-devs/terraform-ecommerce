#!/bin/bash

sudo ssh -i ~/.ssh/key.pem ubuntu@INSTANCE_ID_AZ1

echo "*****************************************************************"
echo "Performing the following actions on Server Instance in AZ1"
echo "*****************************************************************"

sudo apt-get update
sudo apt-get install git -y

echo "--INSTALL NVM TO USE A SPECIFIC NODE VERSION--"
sudo apt-get install curl
sudo curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 18

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
echo "Performing the following actions on Server"
echo "******************************************"

cd /home/ubuntu
sudo rm -rf server || true
sudo git clone <git url>
cd full-ecommerce/
cd web_services
sudo npm install
sudo pm2 kill
sudo kill $(lsof -nt -i4TCP:5002)
sudo pm2 start index.js --name "backend-server"
sudo rm -rf /etc/nginx/sites-available/default
sudo cp server-config /etc/nginx/sites-available/ -r
sudo systemctl kill nginx || true
sudo systemctl start nginx





