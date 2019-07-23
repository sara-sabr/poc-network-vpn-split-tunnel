FROM alpine:latest

# Docker file labels
LABEL description="Proof of Concept image for a internal DNS server."
LABEL version="1.0"
LABEL maintainer="Eric Wu (https://github.com/e-wu)"

RUN apk --no-cache add --update bind \
    && mkdir -p /var/log/bind/ \
    && touch /var/log/bind/rpz.log

COPY config/etc/bind /etc/bind

# DNS port
EXPOSE 53

CMD ["named", "-c", "/etc/bind/named.conf.options", "-g", "-u", "named"]

