# Script for BIOS Configuration via iDRAC
# Author: Piotr Tarnawski
# www.angrysysops.com | Youtube @AngryAdmin | X: @AngrySysOps 

# Function to update BIOS settings and create a job
function Update-BiosSettings {
    param (
        [string]$idracIp,
        [string]$encodedCredentials,
        [PSCustomObject]$biosSettings,
        [string]$phase
    )
    $biosUri = "https://$idracIp/redfish/v1/Systems/System.Embedded.1/Bios/Settings"
    $jobServiceUri = "https://$idracIp/redfish/v1/Managers/iDRAC.Embedded.1/Jobs"
    $jsonBiosSettings = $biosSettings | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $biosUri -Method Patch -Headers @{Authorization=("Basic {0}" -f $encodedCredentials)} -Body $jsonBiosSettings -ContentType "application/json"
        Write-Host "[$phase] BIOS settings updated for iDRAC at $idracIp."

        $jobBody = @{
            TargetSettingsURI = "/redfish/v1/Systems/System.Embedded.1/Bios/Settings"
            RebootJobType = 'PowerCycle'
        } | ConvertTo-Json

        Invoke-RestMethod -Uri $jobServiceUri -Method Post -Headers @{Authorization=("Basic {0}" -f $encodedCredentials)} -Body $jobBody -ContentType "application/json"
        Write-Host "[$phase] Job created to apply settings for iDRAC at $idracIp."

    } catch {
        Write-Host "Error during $phase for iDRAC at ${idracIp}: $_"
    }
}

# Function to check the availability of port 443
function Wait-ForPort {
    param (
        [string]$idracIp,
        [int]$timeoutSeconds = 420
    )
    $timeout = (Get-Date).AddSeconds($timeoutSeconds)
    while ((Get-Date) -lt $timeout) {
        $connection = Test-NetConnection -ComputerName $idracIp -Port 443 -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Host "Port 443 on $idracIp is now available. Proceeding to next phase."
            return
        }
        Start-Sleep -Seconds 10
    }
    Write-Host "Timeout reached waiting for port 443 on $idracIp."
}

# Ignore SSL/TLS certificate validation checks (use with caution)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Prompt for iDRAC credentials
$credential = Get-Credential -Message "Enter your iDRAC credentials"

# Extract username and password
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password

# Convert credentials to base64
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$username`:$password"))

# List of iDRAC IP addresses
$idracIps = @("10.5.12.64") # Add your iDRAC IPs here

# Phase 1: Initial BIOS settings
$initialBiosSettings = @{
    Attributes = @{
        BootMode    = "Uefi"
        TPMSecurity = "On"
        SecureBoot  = "Enabled"        
    }
}
foreach ($idracIp in $idracIps) {
    Update-BiosSettings -idracIp $idracIp -encodedCredentials $encodedCredentials -biosSettings $initialBiosSettings -phase "Phase 1"
}

# Wait for port 443 to become available before initiating Phase 2
Write-Host "Waiting for port 443 to become available before initiating Phase 2..."
Start-Sleep -Seconds 900
Wait-ForPort -idracIp $idracIps[0]

# Phase 2: Update TPM2Algorithm setting
$subsequentBiosSettings = @{
    Attributes = @{
        TPM2Algorithm = "SHA256"   
    }
}
foreach ($idracIp in $idracIps) {
    Update-BiosSettings -idracIp $idracIp -encodedCredentials $encodedCredentials -biosSettings $subsequentBiosSettings -phase "Phase 2"
}

# Wait for port 443 to become available before initiating Phase 3
Write-Host "Waiting for port 443 to become available before initiating Phase 3..."
Start-sleep -Seconds 900
Wait-ForPort -idracIp $idracIps[0]

# Phase 3: Update IntelTXT setting
$subsequentBiosSettings1 = @{
    Attributes = @{
        IntelTXT = "On"
    }
}
foreach ($idracIp in $idracIps) {
    Update-BiosSettings -idracIp $idracIp -encodedCredentials $encodedCredentials -biosSettings $subsequentBiosSettings1 -phase "Phase 3"
}
