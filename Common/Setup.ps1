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
Write-Progress -Id 1 -Activity "Setup Azure Tooling" -Status "Installing Azure Powershell (Choose Yes to all please...)" -PercentComplete 0
Install-Module -Name Az -AllowClobber -Scope CurrentUser
Write-Progress -Id 1 -Activity "Setup Azure Tooling" -Status "Installed Azure Powershell" -PercentComplete 20

# Allow remote signed to run as by default that's blocked. Azure libraries 
# require this.
Write-Progress -Id 1 -Activity "Setup Azure Tooling" -Status "Configure Powershell settings" -PercentComplete 30
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

New-Variable -Name "AZURE_LOCATION" -Value "Canada Central" -Scope Global -Force

Write-Progress -Id 1 -Activity "Setup Azure Tooling" -Status "Prompt to login to Azure" -PercentComplete 50

# Sign to Azure for this session
$IS_LOGGED_IN = Get-AzContext

if (!($IS_LOGGED_IN))
{
  Connect-AzAccount
}

Write-Progress -Id 1 -Activity "Setup Azure Tooling" -Status "Connected to Azure" -PercentComplete 100


