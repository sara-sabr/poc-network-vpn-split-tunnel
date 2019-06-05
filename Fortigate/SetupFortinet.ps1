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

# Local Script variables
$AZURE_RESOURCE_GROUP = "POC-SplitTunnel-Fortinet"
$AZURE_STORAGE_NAME   = (Get-AzContext).Account.Id
$AZURE_STORAGE_NAME   = $AZURE_STORAGE_NAME.Substring(0, $AZURE_STORAGE_NAME.IndexOf('@'))
$AZURE_STORAGE_NAME   = $AZURE_STORAGE_NAME.Replace('.','') + "tunnel"
$GITHUB_PREFIX        = "https://github.com"
$GITHUB_AZURE         = "Azure/azure-devtestlab"
$GITHUB_FORTINET      = "fortinetsolutions/Azure-Templates"
$ARITFACT_DIR         = "../Artifacts"

# Progress bar variables
$ProgressTotalTask    = 4
$ProgressCurrent      = 0

Function Update-Progress([String] $ProgressTask, [Boolean] $Increment) {
  if ($Increment) {
    $ProgressCurrent++
  }

  Write-Progress -Id 2 -Activity "Creating Proof of Concept" -Status $ProgressTask -PercentComplete ($ProgressCurrent/$ProgressTotalTask * 100)
}

Function Get-SourceCode() {
  Write-Host "[GITHUB] " -NoNewline -ForegroundColor Cyan
  Write-Host "Azure DevTestLab Repository                       : " -NoNewline
  Update-Progress("Pulling/Cloning Azure GitHub Repository", $true)
  if (-not (Test-Path "$ARITFACT_DIR/$GITHUB_AZURE")) {
    Invoke-Expression "git clone $GITHUB_PREFIX/$GITHUB_AZURE.git $ARITFACT_DIR/$GITHUB_AZURE 2>&1 | Out-Null"
    Write-Host "Cloned" -ForegroundColor Green
  } else {
    Invoke-Expression "git pull $ARITFACT_DIR/$GITHUB_AZURE 2>&1 | Out-Null"
    Write-Host "Pulled" -ForegroundColor Green
  }

  # FORTINET
  Write-Host "[GITHUB] " -NoNewline -ForegroundColor Cyan
  Write-Host "Azure Fortinet Repository                         : " -NoNewline
  Update-Progress("Pulling/Cloning Fortigate Repository", $true)
  if (-not (Test-Path "$ARITFACT_DIR/$GITHUB_FORTINET")) {
    Invoke-Expression "git clone $GITHUB_PREFIX/$GITHUB_FORTINET.git $ARITFACT_DIR/$GITHUB_FORTINET 2>&1 | Out-Null"
    Write-Host "Cloned" -ForegroundColor Green
  } else {
    Invoke-Expression "git pull $ARITFACT_DIR/$GITHUB_FORTINET 2>&1 | Out-Null"
    Write-Host "Pulled" -ForegroundColor Green
  }  
}

Function Set-PocResourceGroup() {
  # Check for resource group POC-SplitTunnel-Fortinet
  Get-AzResourceGroup -Name $AZURE_RESOURCE_GROUP -ErrorVariable notPresent -ErrorAction SilentlyContinue | Out-Null
  Write-Host "[Resource Group] " -NoNewline -ForegroundColor Cyan
  Write-Host "$AZURE_RESOURCE_GROUP                  : " -NoNewline
  Update-Progress("[Resource Group] Checking for '$AZURE_RESOURCE_GROUP' ...", $true)
  if ($notPresent) {
    Update-Progress("[Resource Group] Creating for '$AZURE_RESOURCE_GROUP' ...", $false)
    New-AzResourceGroup -Name $AZURE_RESOURCE_GROUP  -Tag @{"purpose"="poc"} ` -Location $AZURE_LOCATION | Out-Null
    Write-Host "Created" -ForegroundColor Green -NoNewline
    Remove-Variable -Name "notPresent"
  } else {
    Update-Progress("[Resource Group] Found '$AZURE_RESOURCE_GROUP' ...", $false)
    Write-Host "Exists" -ForegroundColor Green
  }
}

Function Set-PocStorage() {
  # Create storage account with container "image"
  Write-Host "[Storage Account] " -NoNewline -ForegroundColor Cyan
  Write-Host "$AZURE_STORAGE_NAME                             : " -NoNewline
  Update-Progress("[Storage Account] Checking for '$AZURE_STORAGE_NAME' ...", $true)
  Get-AzStorageAccount -Name $AZURE_STORAGE_NAME -ResourceGroupName $AZURE_RESOURCE_GROUP -ErrorVariable notPresent -ErrorAction SilentlyContinue | Out-Null
  if ($notPresent) {
    Update-Progress("[Storage Account] Creating for '$AZURE_STORAGE_NAME' ...", $false)
    $storageAccount  = New-AzStorageAccount -ResourceGroupName $AZURE_RESOURCE_GROUP  -Location $AZURE_LOCATION -AccountName $AZURE_STORAGE_NAME -SkuName Standard_LRS -Kind StorageV2  
    Update-Progress("[Storage Container] Creating 'images' ...", $false)
    New-AzStoragecontainer -Name "images" -Context $storageAccount.Context -Permission blob
    Write-Host "Created" -ForegroundColor Green -NoNewline
    Remove-Variable -Name "notPresent"
  } else {
    Update-Progress("[Storage Account] Found '$AZURE_RESOURCE_GROUP' ...", $false)
    Write-Host "Exists" -ForegroundColor Green
  }
}

Function Copy-PocFortinetToStorage() {
  $storageAccount = Get-AzStorageAccount -Name $AZURE_STORAGE_NAME -ResourceGroupName $AZURE_RESOURCE_GROUP
  Write-Host "[Upload] " -NoNewline -ForegroundColor Cyan
  Write-Host "FortiNet Image                                    : " -NoNewline
  Update-Progress("[Upload] Checking for image/fortios.vhd ...", $true)
  Get-AzStorageBlob -Container "images" -Context $storageAccount.Context -Blob "fortios.vhd" -ErrorVariable notPresent -ErrorAction SilentlyContinue | Out-Null
  if ($notPresent) {
    Update-Progress("[Upload] Uploading 'image/fortios.vhd' ...", $false)
    Set-AzStorageblobcontent -File "$ARITFACT_DIR/VM/Virtual Hard Disks/fortios.vhd" -Container "images" -Blob "fortios.vhd" -Context $storageAccount.Context | Out-Null
    Write-Host "Copied" -ForegroundColor Green -NoNewline
    Remove-Variable -Name "notPresent"
  } else {
    Update-Progress("[Upload] Found 'images/fortios.vhd' ...", $false)
    Write-Host "Exists" -ForegroundColor Green
  }
}

Function Set-PocLab() {
  $LabName = 'POCVPN'
  Write-Host "[DevTestLab] " -NoNewline -ForegroundColor Cyan 
  Write-Host "Checking for $LabName                           : " -NoNewline
}


Function Confirm-PocFortinetImage() {
  $ZIP_FILE = "$ARITFACT_DIR/FGT_VM64_AZURE-v6-FORTINET.out.hyperv.zip"
  Update-Progress("[VM Image] Checking for FortiNet Image... Will pause till it exists", $true)
  Write-Host "[VM Image] " -NoNewline -ForegroundColor Cyan
  Write-Host "Checking for Fortinet Image                     : " -NoNewline
  while (!(Test-Path "$ZIP_FILE")) {
     Write-Host "." -NoNewline
     Start-Sleep 5
  }
  Write-Host "Found" -ForegroundColor Green
  Expand-Archive -Path "$ZIP_FILE" -DestinationPath "$ARITFACT_DIR/VM" -Force
}


Update-Progress("Connect to Azure...", $true)
# Ensure Common is executed.
../Common/Setup.ps1

Write-Host "Summary" 
Write-Host "==================================================================="

# Prerequisites
Write-Host "Prerequisites"
Write-Host "-------------------------------------------------------------------" 
Get-SourceCode
Confirm-PocFortinetImage

Write-Host ""
Write-Host "Azure Configuration"
Write-Host "-------------------------------------------------------------------" 
Set-PocResourceGroup
Set-PocStorage
Copy-PocFortinetToStorage
Set-PocLab
