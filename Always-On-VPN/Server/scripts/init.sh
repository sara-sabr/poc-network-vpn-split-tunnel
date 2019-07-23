#!/bin/sh

# Arguments
# -----------------------------------------------------------------------------
ROOT_CN=$1
SERVER_DOMAIN=$2
VPN_IP_CDR=$3
VPN_DNS=$4

# Script Variable
# -----------------------------------------------------------------------------
PKI_SOURCE_DIRECTORY="/data/pki"
PKI_PRIVATE_CA_KEY="private/ca-key.pem"
PKI_PRIVATE_CA_CERT="private/ca-cert.pem"
PKI_PRIVATE_SERVER_KEY="private/server-key.pem"
PKI_PRIVATE_SERVER_CERT="private/server-cert.pem"
SWAN_SOURCE_DIRECTORY="/data/swan"
SWAN_IPSEC_CONF="ipsec.conf"
SWAN_IPSEC_SECRETS="ipsec.secrets"

# Script body
# -----------------------------------------------------------------------------
mkdir -p $PKI_SOURCE_DIRECTORY/cacerts $PKI_SOURCE_DIRECTORY/certs $PKI_SOURCE_DIRECTORY/private

# Private CA key
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_KEY" ]; then
    ipsec pki --gen --type rsa --size 4096 --outform pem \
    > $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_KEY
fi

# Private CA certificate
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_CERT" ]; then
    ipsec pki --self --ca --lifetime 3650 --in $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_KEY \
    --type rsa --dn "CN=$ROOT_CN" --outform pem \
    > $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_CERT
fi

# Private Server Key
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_KEY" ]; then
    ipsec pki --gen --type rsa --size 4096 --outform pem \
    > $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_KEY
fi

# Private Server certificate
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_CERT" ]; then
    ipsec pki --pub --in $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_KEY  --type rsa \
    | ipsec pki --issue --lifetime 1825 \
        --cacert $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_CERT \
        --cakey $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_KEY \
        --dn "CN=$SERVER_DOMAIN" --san "$SERVER_DOMAIN" \
        --flag serverAuth --flag ikeIntermediate --outform pem \
    > $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_CERT
fi

# Make sure all files now exist. 
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_KEY" ] |
   [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_CERT" ] |
   [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_KEY" ] |
   [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_CERT" ]; then
    >&2 echo "PKI keys are invalid. Provide valid keys or ensure the directory is empty."
    exit 1
fi

# Copy our files over.
cp -r $PKI_SOURCE_DIRECTORY/* /etc/ipsec.d/

mkdir -p $SWAN_SOURCE_DIRECTORY

# ipsec.conf file
# -------------------
if [ ! -f "$SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_CONF" ]; then
    echo "
config setup
    charondebug=\"ike 1, knl 1, cfg 0\"
    uniqueids=no

conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=@$SERVER_DOMAIN
    leftcert=server-cert.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=$VPN_IP_CDR
    rightdns=$VPN_DNS
    rightsendcert=never
    eap_identity=%identity
" >> $SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_CONF   
fi

cp $SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_CONF /etc/$SWAN_IPSEC_CONF

# ipsec.secrets file
# -------------------
if [ ! -f "$SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_SECRETS" ]; then
    # Install pwgen to make our lives easier.
    apk --no-cache add --update pwgen 
    PASSWORD=$(pwgen 16 1)
    echo ": RSA \"server-key.pem\"
pocvpn : EAP \"$PASSWORD\"" >> $SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_SECRETS
fi

cp $SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_SECRETS /etc/$SWAN_IPSEC_SECRETS
