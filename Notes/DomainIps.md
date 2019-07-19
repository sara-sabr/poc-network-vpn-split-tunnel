# Finding domain IPs 

For performance reasons, internet services have caching services offered by:

- [Content Delivery Networks (CDN)](https://en.wikipedia.org/wiki/Content_delivery_network), some examples are:
    - [Amazon Cloudfront](https://aws.amazon.com/cloudfront/)
    - [Akamai](https://www.akamai.com/)
    - [Azure CDN](https://azure.microsoft.com/en-ca/services/cdn/)
    - [Cloudflare](https://www.cloudflare.com/)    
- [Google Global Cache](https://support.google.com/interconnect/answer/9058809?hl=en)

What this results is when a domain is being resolved, you can have different IPs based on:

1. Who is your ISP as they can be performing caching?
2. Where you are geolocated?
3. Random selection

## Figuring out some IPs

To get a best effort list of IPs around the world for a domain name, the following can be performed in Linux

1. ```dig +short youtube.com```
2. ```whois -h whois.radb.net [IP Address returned in #1] | grep -i origin```
3. ```whois -h whois.radb.net -- '-i origin [Text returned in #2]' | grep ^route```
