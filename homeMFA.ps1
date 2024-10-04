# Piotr Tarnawski aka. Angry Admin
# Please subscribe to my YouTube channel as thank you :  https://www.youtube.com/@AngryAdmin
# Follow mw on X:  @AngrySysOps

# Get the desktop path for the current user
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$folderPath = "$desktopPath\test"  # Here one can change the name of the folder you want to be checked ( "$desktopPath\your_folder_name")
$timeout = 15 # seconds , one can modify this value

# Start the timer
$timer = [System.Diagnostics.Stopwatch]::StartNew()

# Check every 1 second if the folder is created
while ($timer.Elapsed.TotalSeconds -lt $timeout) {
    if (Test-Path -Path $folderPath) {
        Write-Host "Folder 'test' detected. No action needed."
        exit
    }
    Start-Sleep -Seconds 1
}

# If the folder was not created within the timeout, reboot the machine
# Write-Host "Folder 'test' not found within $timeout seconds. Rebooting..."
shutdown.exe /r /t 0
