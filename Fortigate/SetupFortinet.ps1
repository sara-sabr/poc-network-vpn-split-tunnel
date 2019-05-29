#requires -version 5.1
<#
.SYNOPSIS
  Create a Fortinet Azure Proof of Concept.
.DESCRIPTION
  Ensure that Fortinet is deployed as a PoC.
.INPUTS
  None
.OUTPUTS
  The URL for Fortinet.
.NOTES
  Version:        1.0
  Author:         Eric Wu
  Creation Date:  2019-05-28
  Purpose/Change: Initial script development
  
.EXAMPLE
  SetupFortinet.ps1
#>

Function Update-Progress([String] $ProgressTask, [Boolean] $Increment)
{
  if ($Increment)
  {
    $ProgressCurrent++
  }

  Write-Progress -Id $ProgressId -Activity $ProgressActivity -Status $ProgressTask -PercentComplete ($ProgressCurrent/$ProgressTotalTask * 100)
}

# Progress bar variables
$ProgressActivity     = "Creating Proof of Concept"
$ProgressId           = 1
$ProgressTotalTask    = 2
$ProgressCurrent      = 0

Write-Host "Summary" 
Write-Host "-------------------------------------------------------------------" 
Update-Progress("Connect to Azure...", $true)

# Ensure Common is executed.
# ../Common/Setup.ps1

# Check for resource group POC-SplitTunnel-Fortinet
Get-AzResourceGroup -Name "POC-SplitTunnel-Fortinet" -ErrorVariable notPresent -ErrorAction SilentlyContinue | Out-Null
Write-Host "[Resource Group] " -NoNewline -ForegroundColor Cyan
Write-Host "POC-SplitTunnel-Fortinet               : " -NoNewline
Update-Progress("[Resource Group] Checking for 'POC-SplitTunnel-Fortinet' ...", $true)
if ($notPresent) {
  Update-Progress("[Resource Group] Creating for 'POC-SplitTunnel-Fortinet' ...", $false)
  New-AzResourceGroup -Name "POC-SplitTunnel-Fortinet" -Tag @{"purpose"="poc"} -Location $AZURE_LOCATION | Out-Null
  Write-Host "Created" -ForegroundColor Green -NoNewline
  Remove-Variable -Name "notPresent"
}
else {
  Update-Progress("[Resource Group] Found 'POC-SplitTunnel-Fortinet' ...", $false)
  Write-Host "Exists" -ForegroundColor Green
}


