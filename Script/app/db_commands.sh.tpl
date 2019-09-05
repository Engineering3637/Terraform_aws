#!/usr/bin/env bash

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add –
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update && sudo apt-get install filebeat --allow-unauthenticated -y
sudo mv /home/ubuntu/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
sudo update-rc.d filebeat defaults 95 10
sudo service filebeat start
mongo
echo 'rs.initiate({
      _id: "rs0",
      members: [
         { _id: 0, host: "10.0.15.150" },
         { _id: 1, host: "10.0.15.151" },
         { _id: 2, host: "10.0.15.152", arbiterOnly:false }]});' | mongo
