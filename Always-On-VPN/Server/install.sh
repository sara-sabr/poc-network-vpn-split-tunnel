#!/bin/sh

# Install docker on the VM assuming Ubuntu.
sudo apt-get update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Install Git to do the pull down since we have no docker repo
sudo apt install git-core -y

# Running as current user
mkdir -p ~/poc-setup
cd ~/poc-setup

# Checkout the code
git clone https://github.com/sara-sabr/poc-network-vpn-split-tunnel-Azure.git

