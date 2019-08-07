#requires -version 5.1
<#
.SYNOPSIS
  Configured to setup Always-On-VPN for the client.
.DESCRIPTION
  This script requuires a domain name to leverage for the VPN configuraiton and will configure 
  the VPN settings accordingly to the PoC. Subsequent runs will replace the VPN settings.
.INPUTS
  DomainName - String - The domain name
  DnsServers - String - The internal DNS servers (comma separated with no spaces)
.OUTPUTS
  Configures your client to connect to the VPN
.NOTES
  Version:        1.0
  Author:         Eric Wu
  Creation Date:  2019-07-15
  Purpose/Change: Initial script development
  
.EXAMPLE
  client-setup.ps1 -domainName [domain name]
#>

# Parameters 
param([String]$DomainName, [String]$DnsServers)

$SquidVersion = "3.5.25"

Write-Host "----------- Progress ----------"
Write-Host "1. Configuring Always On VPN ..."

# Settings
$ProfileName = 'Always-On-VPN-PoC'
$Servers = 'pocvpn.' + $DomainName
$DnsSuffix = 'corp.' + $DomainName
$InternalDomainName = '.corp.' + $DomainName

# Profile XML
$ProfileXML =
'<VPNProfile>
  <DnsSuffix>' + $DnsSuffix + '</DnsSuffix>
  <NativeProfile>
    <Servers>' + $Servers + '</Servers>
    <NativeProtocolType>IKEv2</NativeProtocolType>
    <Authentication>
    <UserMethod>Eap</UserMethod>
        <Eap>
            <Configuration>
                <EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig"><EapMethod><Type xmlns="http://www.microsoft.com/provisioning/EapCommon">26</Type><VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorId><VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorType><AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</AuthorId></EapMethod><Config xmlns="http://www.microsoft.com/provisioning/EapHostConfig"><Eap xmlns="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1"><Type>26</Type><EapType xmlns="http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1"><UseWinLogonCredentials>false</UseWinLogonCredentials></EapType></Eap></Config></EapHostConfig>
            </Configuration>
        </Eap>
    </Authentication>
    <RoutingPolicyType>SplitTunnel</RoutingPolicyType>
    <!-- disable the addition of a class-based route for the assigned IP address on the VPN interface -->
    <DisableClassBasedDefaultRoute>true</DisableClassBasedDefaultRoute>
  </NativeProfile>

  <!-- Inverse split tunneling. Everything by default goes through VPN -->
  <Route>
    <Address>0.0.0.0</Address>
    <PrefixSize>0</PrefixSize>
  </Route>

  <!-- Let localhost through -->
  <Route>
    <Address>127.0.0.1</Address>
    <PrefixSize>32</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>
  </Route>

  <Route>
    <Address>8.8.8.8</Address> <!-- Google DNS -->
    <PrefixSize>32</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>
  </Route>
  <Route>
    <Address>8.8.4.4</Address> <!-- Google DNS -->
    <PrefixSize>32</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>
  </Route>

  <Route>
    <Address>64.68.96.0</Address> <!-- webex -->
    <PrefixSize>19</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>66.114.160.0</Address> <!-- webex -->
    <PrefixSize>20</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>66.163.32.0</Address> <!-- webex -->
    <PrefixSize>19</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>170.133.128.0</Address> <!-- webex -->
    <PrefixSize>18</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>173.39.224.0</Address> <!-- webex -->
    <PrefixSize>19</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>173.243.0.0</Address> <!-- webex -->
    <PrefixSize>20</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>207.182.160.0</Address> <!-- webex -->
    <PrefixSize>19</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>207.182.192.0</Address> <!-- webex -->
    <PrefixSize>19</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>216.151.128.0</Address> <!-- webex -->
    <PrefixSize>19</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>114.29.192.0</Address> <!-- webex -->
    <PrefixSize>19</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>210.4.192.0</Address> <!-- webex -->
    <PrefixSize>20</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>69.26.176.0</Address> <!-- webex -->
    <PrefixSize>20</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>62.109.192.0</Address> <!-- webex -->
    <PrefixSize>18</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>
  <Route>
    <Address>69.26.160.0</Address> <!-- webex -->
    <PrefixSize>20</PrefixSize>
    <ExclusionRoute>true</ExclusionRoute>        
  </Route>  
  <AlwaysOn>false</AlwaysOn>
  <RememberCredentials>true</RememberCredentials>
  <DomainNameInformation>
    <DomainName>' + $InternalDomainName + '</DomainName>
    <DnsServers>' + $DnsServers + '</DnsServers>
  </DomainNameInformation>
  <Proxy>
    <Manual>  
      <Server>127.0.0.1:3128</Server>  
    </Manual>  
  </Proxy>  
</VPNProfile>'

# Properly escape the variables to be used later.
$ProfileNameEscaped = $ProfileName -replace ' ', '%20'
$ProfileXML = $ProfileXML -replace '<', '&lt;'
$ProfileXML = $ProfileXML -replace '>', '&gt;'
$ProfileXML = $ProfileXML -replace '"', '&quot;'

# Configuration of the objects we'll be using.
$nodeCSPURI = "./Vendor/MSFT/VPNv2"
$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_VPNv2_01"

# Get current user SID
try
{
    $username = Get-WmiObject -Class Win32_ComputerSystem | Select-Object username
    $objuser = New-Object System.Security.Principal.NTAccount($username.username)
    $sid = $objuser.Translate([System.Security.Principal.SecurityIdentifier])
    $SidValue = $sid.Value
    $Message = "User SID is $SidValue."
    Write-Host "    $Message"
}
catch [Exception]
{
    $Message = "Unable to get user SID. User may be logged on over Remote Desktop: $_"
    Write-Host "    $Message"
    exit
}

# Define WMI session.
$session = New-CimSession
$options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions
$options.SetCustomOption("PolicyPlatformContext_PrincipalContext_Type", "PolicyPlatform_UserContext", $false)
$options.SetCustomOption("PolicyPlatformContext_PrincipalContext_Id", "$SidValue", $false)

# Delete the old profile if it exists. 
try
{
  $deleteInstances = $session.EnumerateInstances($namespaceName, $className, $options)
  foreach ($deleteInstance in $deleteInstances)
  {
    $InstanceId = $deleteInstance.InstanceID
    if ("$InstanceId" -eq "$ProfileNameEscaped")
    {
    	$session.DeleteInstance($namespaceName, $deleteInstance, $options)
    	$Message = "Removed $ProfileName profile. Instance ID $InstanceId"
    	Write-Host "    $Message"
    } else {
    	$Message = "Ignoring existing VPN profile $InstanceId"
    	Write-Host "    $Message"
    }
  }
}
catch [Exception]
{
  $Message = "Unable to remove existing outdated instance(s) of $ProfileName profile: $_"
  Write-Host "    $Message"
  exit
}

# Create the new profile. 
try
{
  $newInstance = New-Object Microsoft.Management.Infrastructure.CimInstance $className, $namespaceName
  $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ParentID", "$nodeCSPURI", "String", "Key")
  $newInstance.CimInstanceProperties.Add($property)
  $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("InstanceID", "$ProfileNameEscaped", "String", "Key")
  $newInstance.CimInstanceProperties.Add($property)
  $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ProfileXML", "$ProfileXML", "String", "Property")
  $newInstance.CimInstanceProperties.Add($property)
  $session.CreateInstance($namespaceName, $newInstance, $options)
  $Message = "Created $ProfileName profile."

  Write-Host "    $Message"
}
catch [Exception]
{
    $Message = "Unable to create $ProfileName profile: $_"
    Write-Host "    $Message"
    exit
}

$Message = "Script Complete"
Write-Host "    $Message"

$SquidServiceMeasure =  Get-Service -Name "squidsrv" -ErrorAction SilentlyContinue | Measure-Object

if ($SquidServiceMeasure.Count -eq 1) {
  Write-Host "2. Squid Found, so skipping."
}
else {
  Write-Host "2.A. Downloading Squid ..."
  Remove-Item artifacts -Recurse -ErrorAction Ignore
  New-Item -Name artifacts -ItemType directory -ErrorAction Continue
  $msiFile = "http://packages.diladele.com/squid/$SquidVersion/squid.msi"
  Invoke-WebRequest "$msiFile" -OutFile artifacts/squid.msi | Out-Null
  Write-Host "2.A. Installing Squid ..."
  MSIEXEC /i artifacts\squid.msi /qn /log artifacts\install_log.txt ROOTDRIVE=C:\  | Out-Null
}

Write-Host "3. Configure Squid ..."
Copy-Item -Path squid\squid.conf -Destination C:\Squid\etc\squid\squid.conf -Force
Copy-Item -Path squid\realIp.conf -Destination C:\Squid\etc\squid\realIp.conf -Force
Copy-Item -Path squid\whitelist.conf -Destination C:\Squid\etc\squid\whitelist.conf -Force
Copy-Item -Path squid\updateSquid.ps1 -Destination C:\Squid\updateSquid.ps1 -Force 

Remove-Variable -Name "errorNotFound" -ErrorAction SilentlyContinue
Get-ScheduledTask -TaskName "PoC - Update Network for Squid" -ErrorVariable errorNotFound -ErrorAction SilentlyContinue | Out-Null

if ($errorNotFound) {
  Write-Host "4. Add Windows Schedule Task ..."
  $taskData = Get-Content '.\squid\PoC - Update Network for Squid.xml' | Out-String
  Register-ScheduledTask -xml $taskData -TaskName "PoC - Update Network for Squid" -User "NT AUTHORITY\SYSTEM" -Force
  New-EventLog -Source POC-Always-On-VPN -LogName POC-Always-On-VPN
} 