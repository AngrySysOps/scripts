#Author: Piotr Tarnawski aka Angry Admin 
# www.angrysysops.com
#One MUST read README before using this script


$hosts = Get-Cluster "NDC Production Cluster" | Get-VMHost

foreach ($vihost in $hosts){

Write-Host -ForegroundColor Yellow "Host is going into Maintanance Mode"
Set-VMHost -VMHost $vihost -State Maintenance -Confirm:$false

Write-Host -ForegroundColor Yellow "Waiting for host to go in to MM mode" 

sleep 100

 
$esxcli = Get-EsxCli -VMHost $vihost -V2
$esxcliRemoveVibArgs = $esxcli.software.vib.remove.CreateArgs()
#$esxcliRemoveVibArgs.dryrun = $true

Write-Host -ForegroundColor Yellow "Collecting data and removing VIBs"
	
$vibs = $esxcli.software.vib.list.Invoke() | where{$_.Name -match "dell-configuration" -or $_.Name -match "dellemc-osname-idrac" -or $_.Name -match "qedf"  -or $_.Name -match "qedentv-ens"  -or $_.Name -match "qedi" }
	
foreach ($vib in $vibs){
	$esxcliRemoveVibArgs.vibname = $vib.Name 
	$esxcli.software.vib.remove.Invoke($esxcliRemoveVibArgs)
}



Write-Host -ForegroundColor Yellow "Rebooting host"

Restart-VMHost $vihost -Confirm:$false 

 do {

    sleep 100 
    $HostState = (Get-VMHost $vihost).ConnectionState
    write-host -ForegroundColor Red -NoNewline "."
    }
    while ($HostState -ne "NotResponding")
    Write-Host -ForegroundColor Red -NoNewline "(Server is powered down)"

 do {
        sleep 100
        $HostState = (Get-VMHost $vihost).ConnectionState
        Write-Host -ForegroundColor Green -NoNewline "`."
    } while ($HostState -ne "Maintenance")
    Write-Host -ForegroundColor Green "(Server is Powered Up)"

    Write-Host -ForegroundColor Yellow "`tServer Exiting Maintenance Mode"
    Set-VMHost $vihost -State Connected  | Out-Null
    Write-Host -ForegroundColor Yellow "`tHost Reboot Cycle Done!"
    Write-Host ""


}
