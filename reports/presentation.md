# Network Research
VPN - Offloading YouTube and Facebook

![IT Research and Prototyping](https://github.com/sara-sabr/ITResearch-Prototyping/raw/master/assets/img/RP_Logo_Wordmark-EN.png)

[See it in presenttion form](https://sara-sabr.github.io/util-presentation/presentation.html?gh-scope=sara-sabr/poc-network-vpn-split-tunnel&gh-file=reports/presentation.md)

--

## The Idea

When connected to VPN, can we allow YouTube and Facebook traffic to bypass the VPN?

--

## Approach #1 - VPN Split Tunnel

Network administrator configures VPN connection by __whitelisting__ traffic to go through VPN.

---

### Apporach #1 - Description

![Split tunnel vs non-split tunnel](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/VPN-with-and-without-split-tunneling.png)

---

### Apporach #1 - Results

**Configuring Split Tunnel by Routing IP**
![Split Tunel by IP](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/routing-ip.png)

--

## Appraoch #2 - VPN Split Tunnel (Invrese)

All traffic goes through VPN and network administrator whitelisting traffic to __not__ go through VPN.

---

### Apporach #2 - Description

Content...

---

### Apporach #2 - Results

Content...

--

## Approach #3 - VPN Split Tunnel (Inverse) and Proxy

- All traffic goes through VPN and network administrator whitelisting traffic to __not__ go through VPN.
- Use proxy to perform routing decisions as well 

---

### Approach #3 - Description

Content...

---

### Approach #3 - Results

Content... 

--

## Demo

Let's see approach 3 in action.

---

### Demo - Technology Stack

---

### Microsoft Always On VPN

 As of Window 10 1709. we now have [Always On VPN](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/always-on-vpn/always-on-vpn-technology-overview) that has useful [features](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/vpn-map-da).

- Apply rules to individual applications.
- Apply rules to domain names.
- Apply rules to IPs and ports.

--

## The Findings

What did we learn?

---

### Google's YouTube

- Google **shared** IP address pool for all their services in **mulitple** ranges.
  - Globally [400+](https://bgp.he.net/AS15169#_prefixes) ranges.
  - Canada is roughly specifc IPs of 172.217.0.0/16

- Google video streaming has a domain of *.googlevideo.com
  - Google Global Caching (GCC) has implications on geolocation and even ISPs
  - Subdomains are generated on the fly. Forcing targetted specific IPs on this domain is problematic 

--

## Recommendation

- Unless we can get inverse split tunnel based on domain names, IP selection will be problematic.
  - Requires COTS products.
  - Microsoft Always On VPN only does split tunnel and not inverse split tunnel
- Sandbox internet browsing option through a VM
  - This topic moved to multiple laptop discussion as options better aligned there.
- Facebook offloading has similar issues.

--

## References

- Google Global Cache usage described in [this paper](https://vaibhavbajpai.com/documents/papers/proceedings/youtube-load-balancing-pam-2018.pdf).
- [Where Google DNS are locationed](https://developers.google.com/speed/public-dns/faq#locations)
- [Google FAQ on Peering](https://peering.google.com/#/learn-more/faq)
- [Reverse Engineering YouTube](https://tyrrrz.me/Blog/Reverse-engineering-YouTube)


--

## Questions?
