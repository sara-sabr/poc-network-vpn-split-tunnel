#!/bin/sh


# Script Variable
# -----------------------------------------------------------------------------
PKI_SOURCE_DIRECTORY="/poc-data/pki"
PKI_PRIVATE_CA_KEY="private/ca-key.pem"
PKI_PRIVATE_CA_CERT="cacerts/ca-cert.pem"
PKI_PRIVATE_SERVER_KEY="private/server-key.pem"
PKI_PRIVATE_SERVER_CERT="certs/server-cert.pem"
SWAN_SOURCE_DIRECTORY="/poc-data/swan"
SWAN_IPSEC_CONF="ipsec.conf"
SWAN_IPSEC_SECRETS="ipsec.secrets"

echo "========================================================================"
echo "Configuring ..."
echo "========================================================================"

# Script body
# -----------------------------------------------------------------------------
mkdir -p $PKI_SOURCE_DIRECTORY/cacerts $PKI_SOURCE_DIRECTORY/certs $PKI_SOURCE_DIRECTORY/private

if [ ! -d "$PKI_SOURCE_DIRECTORY" ]; then
    echo "Directory somehow does not exist?"
fi

# Private CA key
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_KEY" ]; then
    echo "    Creating Private Root Key ..."
    ipsec pki --gen --type rsa --size 4096 --outform pem \
    > $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_KEY
fi

# Private CA certificate
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_CERT" ]; then
    echo "    Creating Private Root Certificate ..."
    ipsec pki --self --ca --lifetime 3650 --in $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_KEY \
    --type rsa --dn "CN=$ROOT_CN" --outform pem \
    > $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_CA_CERT
fi

# Private Server Key
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_KEY" ]; then
    echo "    Creating Private Server Key ..."
    ipsec pki --gen --type rsa --size 4096 --outform pem \
    > $PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_KEY
fi

# Private Server certificate
if [ ! -f "$PKI_SOURCE_DIRECTORY/$PKI_PRIVATE_SERVER_CERT" ]; then
    echo "    Creating Private Server Certificate ..."
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
    echo "    [WARNING] Misconfigured. Exiting."
    exit 1
fi

# Copy our files over.
cp -r $PKI_SOURCE_DIRECTORY/* /etc/ipsec.d/

mkdir -p $SWAN_SOURCE_DIRECTORY

# ipsec.conf file
# -------------------
if [ ! -f "$SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_CONF" ]; then
    echo "    Create ipsec.conf ..."
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
    ike=aes128gcm16-prfsha384-ecp25
    esp=aes128gcm16-ecp256,aes128-sha2_512-prfsha512-ecp256!
" >> $SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_CONF   
fi

cp $SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_CONF /etc/$SWAN_IPSEC_CONF

# ipsec.secrets file
# -------------------
if [ ! -f "$SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_SECRETS" ]; then
    echo "    Create ipsec.secrets ..."
    # Install pwgen to make our lives easier.
    apk --no-cache add --update pwgen 
    PASSWORD=$(pwgen 16 1)
    echo ": RSA \"server-key.pem\"
pocvpn : EAP \"$PASSWORD\"" >> $SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_SECRETS
fi

cp $SWAN_SOURCE_DIRECTORY/$SWAN_IPSEC_SECRETS /etc/$SWAN_IPSEC_SECRETS

echo "========================================================================"
echo "IP Tables for VPN netowork ${VPN_IP_CDR}"
echo "========================================================================"
iptables -t nat -A POSTROUTING -s ${VPN_IP_CDR} -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
iptables -t nat -A POSTROUTING -s ${VPN_IP_CDR} -o eth0 -j MASQUERADE
iptables -t mangle -A FORWARD --match policy --pol ipsec --dir in  -s ${VPN_IP_CDR} -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
iptables -t filter -A FORWARD --match policy --pol ipsec --dir in --proto esp -s ${VPN_IP_CDR} -j ACCEPT
iptables -t filter -A FORWARD --match policy --pol ipsec --dir out --proto esp -d ${VPN_IP_CDR} -j ACCEPT

echo "========================================================================"
echo "VPN Server Starting ..."
echo "========================================================================"


ipsec start --nofork