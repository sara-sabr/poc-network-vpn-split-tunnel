#requires -version 5.1
<#
.SYNOPSIS
  Removes the PoC.
.DESCRIPTION
  This script will remove the PoC.
.INPUTS
  None
.OUTPUTS
  Removes the PoC
.NOTES
  Version:        1.0
  Author:         Eric Wu
  Creation Date:  2019-08-07
  Purpose/Change: Initial script development
  
.EXAMPLE
  client-remove.ps1
#>

Write-Host "1. Remove Scheduled Task ..."
Unregister-ScheduledTask -TaskName "PoC - Update Network for Squid" -ErrorAction SilentlyContinue -Confirm:$false
Remove-EventLog -LogName POC-Always-On-VPN -Confirm:$false

Write-Host "2. Remove Squid ..."
$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'Squid'"

if ($app) {
    $app.Uninstall()
}

Write-Host "3. Remove VPN ..."
# Properly escape the variables to be used later.
$ProfileNameEscaped = $ProfileName -replace ' ', '%20'
$ProfileXML = $ProfileXML -replace '<', '&lt;'
$ProfileXML = $ProfileXML -replace '>', '&gt;'
$ProfileXML = $ProfileXML -replace '"', '&quot;'

# Configuration of the objects we'll be using.
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
$ProfileName = 'Always-On-VPN-PoC'
$ProfileNameEscaped = $ProfileName -replace ' ', '%20'
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
