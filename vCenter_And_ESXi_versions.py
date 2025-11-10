#Author Piotr Tarnawski
# Angry Admin - www.angrysysops.com 
# @AngrySysOps (currently susspended) @@TheTechWorldPod - my new podcast

# --- Step 1: Connect to your vCenter Server ---
# Replace "vcenter.yourdomain.com" with your vCenter Server's FQDN or IP address
# A credential window will pop up for you to enter your username and password.
Connect-VIServer -Server "vcenter.yourdomain.com"

# --- Step 2: Get vCenter Server Version ---
Write-Host "--- vCenter Server Version ---" -ForegroundColor Green
$global:DefaultVIServers | Select-Object Name, Version, Build | Format-List
Write-Host "" # Adds a blank line for readability

# --- Step 3: Get All ESXi Host Versions ---
Write-Host "--- ESXi Host Versions ---" -ForegroundColor Green
Get-VMHost | Select-Object Name, Version, Build | Format-Table -AutoSize

# --- Step 4: Disconnect from the vCenter Server (Optional) ---
Write-Host "--- Disconnecting session ---"
Disconnect-VIServer -Server "*" -Confirm:$false
