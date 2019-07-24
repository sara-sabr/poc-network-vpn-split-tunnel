#!/bin/sh

# Install docker on the VM assuming Ubuntu.
sudo apt-get update
sudo apt install docker.io -y
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

# Build the DNS server
cd poc-network-vpn-split-tunnel-Azure/
pushd .

cd Always-On-VPN/Server/DNS
sudo docker build . -t esdc-rp-poc-vpn-dns:latest
sudo docker run  -p 53:53/udp  esdc-rp-poc-vpn-dns:latest



