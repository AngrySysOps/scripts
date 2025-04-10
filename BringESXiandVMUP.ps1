# Piotr Tarnawski aka. Angry Admin
# Please subscribe to my YouTube channel as thank you :  https://www.youtube.com/@AngryAdmin
# Follow mw on X:  @AngrySysOps

Connect-VIServer <vCenter_name>

$clusterName = 'your_cluster_name'

# Retrieve the cluster by iterating through datacenters and clusters
$cluster = Get-Datacenter | Get-Cluster | Where-Object { $_.Name -eq $clusterName }

if ($null -eq $cluster) {
    Write-Host "Cluster not found!"
    exit
}

# Get all ESXi hosts in the specified cluster
$esxiHosts = Get-VMHost -Location $cluster

foreach ($esxi in $esxiHosts) {
    Write-Host "Processing host: $($esxi.Name)"
    
    # Keep checking until the host is no longer in maintenance mode
    while ($esxi.ConnectionState -eq "Maintenance") {
        Write-Host "Exiting maintenance mode for host: $($esxi.Name)"
        Set-VMHost -VMHost $esxi -State "Connected" -Confirm:$false
        Start-Sleep -Seconds 60
        
        # Refresh the host object to get the updated state
        $esxi = Get-VMHost -Name $esxi.Name
    }
    
    # Check and power on VMs once the host is connected
    $vms = Get-VM -Location $esxi
    foreach ($vm in $vms) {
        if ($vm.PowerState -eq "PoweredOff") {
            Write-Host "Powering on VM: $($vm.Name) on host: $($esxi.Name)"
            Start-VM -VM $vm
        }
    }
}

# Disconnecting from vCneter
Disconnet-Viserver *
