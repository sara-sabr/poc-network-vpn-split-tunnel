# Client

## Description

With client side VPN configurations pushed by Intune or SCCM, we can pre-configure the VPN clients and leverage more than just the network IP address space for routing table.

## Requirements

- Minimum of Microsoft Windows 10 1709

## Install

1. Open PowerShell with admin rights
2. Run the following:
  ```powershell
  .\client-setup.ps1 -DomainName <put a domain name> -DnsServers <DNS servers comma separate>
  ```
3. Import the certificate ca-cert.pem to your local computer - Trusted Root