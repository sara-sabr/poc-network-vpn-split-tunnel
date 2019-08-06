$interfaceIdx = Get-NetRoute -DestinationPrefix  "0.0.0.0/0" | Sort-Object -Property InterfaceMetric | Select -ExpandProperty ifIndex -Skip 1 -First 1
$ipAddress = Get-NetIPAddress -InterfaceIndex $interfaceIdx | Select -ExpandProperty IPv4Address
Set-Content -Value "tcp_outgoing_address $ipAddress whiteliststream " -Path realIp.conf
Restart-Service