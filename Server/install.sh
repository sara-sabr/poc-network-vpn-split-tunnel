#!/bin/sh

# Install docker on the VM assuming Ubuntu.
sudo apt-get update
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker

sudo ufw allow ssh
sudo ufw allow 53
sudo ufw allow 500,4500/udp

sudo sed -i '\/net\/ipv4\/ip_forward/s/^#//g'  /etc/ufw/sysctl.conf
echo "net/ipv4/conf/all/send_redirects=0
net/ipv4/ip_no_pmtu_disc=1"  | sudo tee -a /etc/ufw/sysctl.conf

sudo ufw enable 
sudo ufw reload

# Install Git to do the pull down since we have no docker repo
sudo apt install git-core -y

# Running as current user
mkdir -p ~/poc-setup
cd ~/poc-setup

# Checkout the code
git clone https://github.com/sara-sabr/poc-network-vpn-split-tunnel.git

cd poc-network-vpn-split-tunnel/Server
sudo chmod 700 start.sh
sudo chmod 700 stop.sh
sudo ./start.sh