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

# Get the server's IP address, assuming eth0 is the accessible IP. 
listenIP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

# Build the DNS Docker image (Move this to a docker repository)
cd Always-On-VPN/Server/DNS
sudo docker build . -t esdc-rp-poc-vpn-dns:latest

# Bring up DNS docker
dockerPort="$listenIP:53"
sudo docker run  -d -p $dockerPort:53/udp  esdc-rp-poc-vpn-dns:latest



