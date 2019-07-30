#!/bin/sh

# Get the server's IP address, assuming eth0 is the accessible IP. 
export DOCKER_PUBLIC_IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
docker-compose down

