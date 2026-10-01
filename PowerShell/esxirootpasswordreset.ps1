# Piotr Tarnawski aka Angry Admin 
# @AngrySysOpsHQ
# 1. Define Variables
$vCenterServer = "vcenter01.angrysysops.com"
$TargetHosts = @(
    "esx-host01.angrysysops.com",
    "esx-host02.angrysysops.com"
)

# 2. Connect to the vCenter Server
Connect-VIServer -Server $vCenterServer

# 3. Prompt for the NEW root password
# (Leave username as "root", type the NEW password in the password field)
$Creds = Get-Credential -UserName "root" -Message "Enter the NEW root password for the ESXi hosts"

# 4. Iterate through each host and update the password
foreach ($HostFQDN in $TargetHosts) {
    Write-Host "Processing host: $HostFQDN" -ForegroundColor Cyan

    try {
        # Retrieve the VMHost object
        $VMHostObj = Get-VMHost -Name $HostFQDN -ErrorAction Stop

        # Map the ESXCLI v2 namespace
        $EsxCli = Get-EsxCli -VMHost $VMHostObj -V2

        # Build the payload for the account modification
        $UserArg = $EsxCli.system.account.set.CreateArgs()
        $UserArg.id = "root"
        $UserArg.password = $Creds.GetNetworkCredential().Password
        $UserArg.passwordconfirmation = $Creds.GetNetworkCredential().Password

        # Invoke the password change
        $Result = $EsxCli.system.account.set.Invoke($UserArg)
        if ($Result -eq $true) {
            Write-Host "Successfully updated root password on $HostFQDN" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Failed to update password on $HostFQDN. Error: $_" -ForegroundColor Red
    }
}

# 5. Disconnect from vCenter
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
