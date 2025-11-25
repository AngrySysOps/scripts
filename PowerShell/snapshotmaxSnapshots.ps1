#This script changes limit of snapshots to 1
#This script fix the error "Exceeded the maximum number of permitted snapshots"
#Author: Piotr Tarnawski aka Angry Admin 
# www.angrysysops.com
#One MUST read README before using this script
#Full explanationn of this code : https://angrysysops.com/2022/08/12/a-general-system-error-occurred-exceeded-the-maximum-number-of-permitted-snapshots-error-when-creating-a-virtual-machine-snapshot/

Disconnect-server *
Connect-VIServer 

$snapcheck = Get-VM | where name -Like "*nsxt*"

# where name -Like "*nsxt*" this is just to sort all VM with nsxt in the name, you can drop this condition. 

foreach ($snap in $snapcheck) {
     $test = $snapcheck | Get-AdvancedSetting 'snapshot.maxSnapshots'
     if ($test -eq $null) {
         New-AdvancedSetting -Name snapshot.maxSnapshots -Value 1 -Entity -Confirm:$false -Force:$true
         }
         else {
              $test | where value -ne 1 | Set-AdvancedSetting -Value 1 -Confirm:$false
              }
}
