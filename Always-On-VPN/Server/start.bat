@echo off

echo. 
if "%SERVER_DOMAIN%" == "" (
    echo Error: Please set environment variable 'SERVER_DOMAIN'.
    GOTO end
)
if "%VPN_IP_CDR%" == "" (
    echo Please set environment variable 'VPN_IP_CDR'. Also, please make sure the mask is greater than /24.
    GOTO end
)

set DOCKER_PUBLIC_IP=127.0.0.1
docker-compose build
docker-compose up
:end

