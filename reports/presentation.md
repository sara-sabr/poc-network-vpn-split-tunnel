# Network Research
VPN Split Tunnel (Inverse)

![IT Research and Prototyping](https://github.com/sara-sabr/ITResearch-Prototyping/raw/master/assets/img/RP_Logo_Wordmark-EN.png)

---

## The Idea

When an user is on the VPN, can we allow YouTube and Facebook traffic to bypass the VPN.

--

### What is Split Tunnel?

![Split tunnel vs non-split tunnel](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/VPN-with-and-without-split-tunneling.png)

--

### What is Inverse Split Tunnel?

**Split tunnel**
- Network administrator configures VPN connection by __whitelisting__ traffic to go through VPN.

**Inverse split tunnel**
- All traffic goes through VPN and network administrator whitelisting traffic to not go through VPN.

--- 

### Configuring Split Tunnel by Routing IP

![Split tunnel vs non-split tunnel](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/routing-ip.png)

--- 

### Configuring Split Tunnel by Routing Domain

![Split tunnel vs non-split tunnel](https://github.com/sara-sabr/poc-network-vpn-split-tunnel/raw/master/reports/assets/routing-domain.png)

- Not all vendor solutions support this. Initial scan resulted in:
    - [Cisco AnyConnect](https://www.cisco.com/c/en/us/td/docs/security/asa/asa91/asdm71/vpn/asdm_71_vpn_config/vpn_asdm_dap.html#15525)
    - [Paloaltonetworks](https://docs.paloaltonetworks.com/pan-os/8-1/pan-os-new-features/globalprotect-features/split-tunnel-for-public-applications#)

---


## The Outcome

 VPN solutions in general support split tunnel. Support for inverse split tunnel is limited as the practice is to whitelist what needs to go through VPN and not the other way around. 

-- 

 ### Microsoft Always On VPN

 As of Window 10 1709. we now have [Always On VPN](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/always-on-vpn/always-on-vpn-technology-overview) that has useful [features](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/vpn-map-da).
 - Apply rules to individual applications.
 - Apply rules to domain names.
 - Apply rules to IPs and ports.

---

## The Findings

---

## Demo

---

## Questions?
