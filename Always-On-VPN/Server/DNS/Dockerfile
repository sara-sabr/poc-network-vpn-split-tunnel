FROM alpine:latest

# Docker file labels
LABEL description="Proof of Concept image for a internal DNS server."
LABEL version="1.0"
LABEL maintainer="Eric Wu (https://github.com/e-wu)"

# RUN apk --no-cache add --update bind \
#    && mkdir -p /var/log/bind/ \
#    && touch /var/log/bind/rpz.log \
#    && chown -R named:named /var/log/bind

# COPY config/etc/bind /etc/bind

COPY config/etc/ /root/etc/ 
RUN apk --no-cache add --update unbound  \
    && cp -f /root/etc/unbound/unbound.conf /etc/unbound/unbound.conf \ 
    && rm -rf /root/etc/ \
    && unbound-checkconf

# DNS port
EXPOSE 53

ENTRYPOINT [ "/usr/sbin/unbound" , "-d" ]

