#!/bin/sh

if [ -z "$SERVER_DOMAIN" ]; then
    echo "Please set environment variable 'SERVER_DOMAIN'."
    read -p "Specify VPN HOST Name :" SERVER_DOMAIN    
    export SERVER_DOMAIN
fi

if [ -z "$VPN_IP_CDR" ]; then
    echo "Please set environment variable 'VPN_IP_CDR'. Also, please make sure the mask is greater than /24."
    read -p "Specify VPN_IP_CDR :" VPN_IP_CDR
    export VPN_IP_CDR
fi


# Get the server's IP address, assuming eth0 is the accessible IP. 
export DOCKER_PUBLIC_IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
docker-compose build
docker-compose up -d

while [ ! -f config/swan/ipsec.secrets ] | [ ! -f config/ipsec/cacerts/cacerts/ca-cert.pem ];
do
      sleep 2
done

echo "---------------------------------------------------------------------------------"
echo "Connecting to VPN Details ..."
echo "---------------------------------------------------------------------------------"

echo "The Certificate you need locally as a computer trusted root is found in:"
pwd config/ipsec/cacerts/cacerts/ca-cert.pem
echo ""
echo "The account password is (username : password) : "
accountDetails=$(tail -n 1 config/swan/ipsec.secrets)
accountDetails=${accountDetails//\"/ }
accountDetails=${accountDetails// EAP / }
echo "$accountDetails"

