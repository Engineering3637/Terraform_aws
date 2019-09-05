#!/usr/bin/env bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add –
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update && sudo apt-get install filebeat --allow-unauthenticated -y
sudo mv /home/ubuntu/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
sudo update-rc.d filebeat defaults 95 10
sudo service filebeat start
cd /home/ubuntu/app

sudo npm install
node app.js
