#requires -version 5.1
<#
.SYNOPSIS
  Configured to run powershell in an Azure subscription.
.DESCRIPTION
  Ensure that the device is ready to access Azure subscriptions. 
  To prevent secret leaks, this script must be executed everytime.
.INPUTS
  None
.OUTPUTS
  The following variables are configured upon completion:
      - AZURE_LOCATION
.NOTES
  Version:        1.0
  Author:         Eric Wu
  Creation Date:  2019-05-28
  Purpose/Change: Initial script development
  
.EXAMPLE
  Setup.ps1
#>

## ============================================================================
## Execute steps in https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-2.1.0
## ============================================================================

# Install 
Write-Host "Installing Azure Powershell (Choose Yes to all please...)"
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Allow remote signed to run as by default that's blocked. Azure libraries 
# require this.
Write-Host "Allow Azure Powershell to run (Choose Yes to all please...)"
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

New-Variable -Name "AZURE_LOCATION" -Value "Canada Central"

# Sign to Azure for this session
Connect-AzAccount

