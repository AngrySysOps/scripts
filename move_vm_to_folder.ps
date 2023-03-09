Connect-VIServer 



Import-Csv "C:\temp\VmList.csv" | %{
    $vm = Get-VM -Name $_.Name
    $folder = Get-Folder -Name "Folder_Name"

    try {
        Move-VM -VM $vm -Destination $folder -ErrorAction Stop
    }
    catch {
        Write-Host "Error moving VM $($vm.Name): $($_.Exception.Message)"
    }
}

Disconnect-VIServer -Confirm:$false
