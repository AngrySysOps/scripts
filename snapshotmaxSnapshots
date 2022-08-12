Disconnect-server *
Connect-VIServer 

$snapcheck = Get-VM | where name -Like "*nsxt*"

foreach ($snap in $snapcheck) {
     $test = $snapcheck | Get-AdvancedSetting 'snapshot.maxSnapshots'
     if ($test -eq $null) {
         New-AdvancedSetting -Name snapshot.maxSnapshots -Value 1 -Entity -Confirm:$false -Force:$true
         }
         else {
              $test | where value -ne 1 | Set-AdvancedSetting -Value 1 -Confirm:$false
              }
}
