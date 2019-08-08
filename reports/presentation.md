# Network Research
VPN - Offloading YouTube and Facebook

![IT Research and Prototyping](https://github.com/sara-sabr/ITResearch-Prototyping/raw/master/assets/img/RP_Logo_Wordmark-EN.png)

[See it in presenttion form](https://sara-sabr.github.io/util-presentation/presentation.html?gh-scope=sara-sabr/poc-network-vpn-split-tunnel&gh-file=reports/presentation.md)

---

## The Idea

When connected to VPN, can we allow YouTube and Facebook traffic to bypass the VPN?

---

## Approach #1 - VPN Split Tunnel

Network administrator configures VPN connection by __whitelisting__ traffic to go through VPN.

--

### Apporach #1 - Description

![Split tunnel vs non-split tunnel](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/VPN-with-and-without-split-tunneling.png)

--

### Apporach #1 - Results

**Configuring Split Tunnel by Routing IP**

- The [industry standard](https://www.iana.org/assignments/iana-ipv4-special-registry/iana-ipv4-special-registry.xhtml) for private networking are:
  - *10.0.0.0* to *10.255.255.255*
  - *172.16.0.0* to *172.31.255.255*
  - *192.168.0.0* to *192.168.255.255*
- Just configuring these IPs would result in everything else going to the internet. 
  - Excluding YouTube and Facebook results in a large amount of ranges that will not be  sustainable.

---

## Appraoch #2 - Inverse VPN Split Tunnel

All traffic goes through VPN and network administrator whitelists traffic to __not__ go through VPN.

--

### Apporach #2 - Description

![Inverse Split-Tunnel](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/approach2-ip.png)

--

### Apporach #2 - Results

- Google **shared** IP address pool for all their services in **mulitple** ranges.
  - Globally [400+](https://bgp.he.net/AS15169#_prefixes) ranges.
- Google video streaming has a domain of *.googlevideo.com
  - Google Global Caching (GCC) has implications on geolocation and even ISPs
  - Subdomains are generated on the fly. Forcing targetted specific IPs on this domain is problematic 
- We really want to look at domain names to decide whether it goes to internet or VPN.

---

## Approach #3 - Inverse VPN Split Tunnel and Proxy

- All traffic goes through VPN and network administrator whitelists traffic to __not__ go through VPN.
- In addition, proxy to perform traffic decisions by domain name

--

### Approach #3 - Description


![Inverse Split-Tunnel with Proxy](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/approach3-domain.png)

--

### Approach #3 - Results

- Maintenance was extremely simple
- Can track what employees access in log file 
- Proxy is only active during VPN connection

---

## Demo

Let's see **Approach #3** in action.

--

### Demo - Technology Stack

- Client 
  - VPN Software - Microsoft [Always On VPN](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/always-on-vpn/always-on-vpn-technology-overview)
  - Proxy - [Squid Proxy](http://www.squid-cache.org/) 
  - Configuration - Windows scheduled task to detect when VPN is active
- Server
  - Docker containers for:
    - DNS - [Unbound](https://nlnetlabs.nl/projects/unbound/about/)
    - VPN Server - [strongSwan](https://www.strongswan.org/) using IKEv2 

--

### Microsoft Always On VPN

 As of Window 10 1709. we now have [Always On VPN](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/always-on-vpn/always-on-vpn-technology-overview) that has useful [features](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/vpn-map-da).

- Apply rules to individual applications.
- Apply rules to domain names.
- Apply rules to IPs and ports.

---

## Recommendation

- Approach #3 - Inverse split tunnel VPN and proxy resulted in the best experience
- We can log standard internet traffic information through use of the proxy
  - This log could be uploaded to a on-premise central log server

--

### Further items 

- The proof of concept leveraged Squid which appears to be 2 years old.
  - Vendor having issues porting Squid to Windows from Linux
  - Find another proxy software for Windows
- Test VPN vendor implementations that supports similar configurations (high level scan)
  - [Cisco AnyConnect](https://www.cisco.com/c/en/us/td/docs/security/asa/asa91/asdm71/vpn/asdm_71_vpn_config/vpn_asdm_dap.html#15525)
  - [Paloaltonetworks](https://docs.paloaltonetworks.com/pan-os/8-1/pan-os-new-features/globalprotect-features/split-tunnel-for-public-applications#)

--

## Run the demo yourself

![GitHub Icon](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/github.png)
[https://github.com/sara-sabr/poc-network-vpn-split-tunnel](https://github.com/sara-sabr/poc-network-vpn-split-tunnel)

---

## References

- Google Global Cache usage described in [this paper](https://vaibhavbajpai.com/documents/papers/proceedings/youtube-load-balancing-pam-2018.pdf).
- [Where Google DNS are locationed](https://developers.google.com/speed/public-dns/faq#locations)
- [Google FAQ on Peering](https://peering.google.com/#/learn-more/faq)
- [Reverse Engineering YouTube](https://tyrrrz.me/Blog/Reverse-engineering-YouTube)

---

## Questions
