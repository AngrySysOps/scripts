# Piotr Tarnawski aka. Angry Admin
# Please subscribe to my YouTube channel as thank you :  https://www.youtube.com/@AngryAdmin
# Follow mw on X:  @AngrySysOps

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

    # Check if the host is powered on. If not, wait until it is powered on.
    while ($esxi.PowerState -eq "PoweredOff") {
        Write-Host "Host $($esxi.Name) is powered off. Waiting for it to power on..."
        Start-Sleep -Seconds 60
        # Refresh the host object for current status.
        $esxi = Get-VMHost -Name $esxi.Name
    }

    # Once the host is powered on, check for maintenance mode.
    while ($esxi.ConnectionState -eq "Maintenance") {
        Write-Host "Host $($esxi.Name) is in maintenance mode. Exiting maintenance mode..."
        Set-VMHost -VMHost $esxi -State "Connected" -Confirm:$false
        Start-Sleep -Seconds 60
        # Refresh the host object to get the updated state.
        $esxi = Get-VMHost -Name $esxi.Name
    }

    # After ensuring the host is powered on and connected, power on any powered-off VMs.
    $vms = Get-VM -Location $esxi
    foreach ($vm in $vms) {
        if ($vm.PowerState -eq "PoweredOff") {
            Write-Host "Powering on VM: $($vm.Name) on host: $($esxi.Name)"
            Start-VM -VM $vm
        }
    }
}
