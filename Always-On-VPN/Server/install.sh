#!/bin/sh

# Install docker on the VM assuming Ubuntu.
sudo apt-get update
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker

sudo ufw allow ssh
sudo ufw allow dns
sudo ufw enable 

# Install Git to do the pull down since we have no docker repo
sudo apt install git-core -y

# Running as current user
mkdir -p ~/poc-setup
cd ~/poc-setup

# Checkout the code
git clone https://github.com/sara-sabr/poc-network-vpn-split-tunnel-Azure.git

sudo chmod 700 start.sh
sudo chmod 700 stop.sh
sudo ./start.sh