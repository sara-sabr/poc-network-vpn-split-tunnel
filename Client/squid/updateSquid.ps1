$interfaceIdx = Get-NetRoute -DestinationPrefix  "0.0.0.0/0" | Sort-Object -Property InterfaceMetric | Select -ExpandProperty ifIndex -Skip 1 -First 1
Write-EventLog -LogName POC-Always-On-VPN -Source POC-Always-On-VPN -EventID 100 -EntryType Information -Message 'Executing Task on Network Connection ...'

if ($interfaceIdx) {
    $ipAddress = Get-NetIPAddress -InterfaceIndex $interfaceIdx | Select-Object -ExpandProperty IPv4Address
    Write-EventLog -LogName POC-Always-On-VPN -Source POC-Always-On-VPN -EventID 100 -EntryType Information -Message "Updating IP to $ipAddress"
    Set-Content -Value "tcp_outgoing_address $ipAddress whiteliststream " -Path C:\Squid\etc\squid\realIp.conf -Force
    Write-EventLog -LogName POC-Always-On-VPN -Source POC-Always-On-VPN -EventID 100 -EntryType Information -Message 'Restarting Squid'
    Restart-Service -Name "squidsrv"
}
exit