# The script will perform the following actions:

# Connect to the iDRAC.
# Change the specified BIOS settings.
# Create a job to apply these settings on the next reboot.
# author: Piotr Tarnawski.
# angrysysops.com | X: @Angrysysops | YT: https://www.youtube.com/@AngryAdmin 

# Ignore SSL/TLS certificate validation checks (use with caution)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }


# Prompt for iDRAC credentials
$credential = Get-Credential -Message "Enter your iDRAC credentials"

# Extract username and password from the credentials object
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password

# Convert credentials to base64
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$username`:$password"))

# List of iDRAC IP addresses
$idracIps = @("10.5.12.40", "10.5.12.41", "10.5.12.42")

# BIOS settings to change
$biosSettings = @{
    Attributes = @{
        BootMode    = "Uefi"
        TPMSecurity = "On"
        IntelTXT    = "On"
        SecureBoot  = "Enabled"
        # add more atributes or remove as you need
    }
}

# Convert the settings to JSON
$jsonBiosSettings = $biosSettings | ConvertTo-Json

foreach ($idracIp in $idracIps) {
    # iDRAC API URI for BIOS settings
    $biosUri = "https://$idracIp/redfish/v1/Systems/System.Embedded.1/Bios/Settings"
    # iDRAC API URI for creating a job
    $jobServiceUri = "https://$idracIp/redfish/v1/Managers/iDRAC.Embedded.1/Jobs"

    # Apply BIOS settings
    try {
        Invoke-RestMethod -Uri $biosUri -Method Patch -Headers @{Authorization=("Basic {0}" -f $encodedCredentials)} -Body $jsonBiosSettings -ContentType "application/json"
        Write-Host "BIOS settings updated successfully for iDRAC at $idracIp. Visit angrysysops.com for more info!"

        # Create job for BIOS settings
        $jobBody = @{
            TargetSettingsURI = "/redfish/v1/Systems/System.Embedded.1/Bios/Settings"
            } | ConvertTo-Json

        Invoke-RestMethod -Uri $jobServiceUri -Method Post -Headers @{Authorization=("Basic {0}" -f $encodedCredentials)} -Body $jobBody -ContentType "application/json"
        Write-Host "Job created to apply settings for iDRAC at $idracIp. Visit angrysysops.com for more info!"

    } catch {
        Write-Host "Error updating BIOS settings or creating job for iDRAC at ${idracIp}: $_"
    }
}
