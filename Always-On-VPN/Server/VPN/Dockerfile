FROM alpine:latest

# Docker file labels
LABEL description="Proof of Concept image for a StrongSwan VM."
LABEL version="1.0"
LABEL maintainer="Eric Wu (https://github.com/e-wu)"

COPY scripts /poc-setup/scripts/

RUN apk --no-cache add --update strongswan \ 
    && chmod 700 /poc-setup/scripts/init.sh    

# DNS port
EXPOSE 500 4500

ENTRYPOINT [ "/poc-setup/scripts/init.sh"]





