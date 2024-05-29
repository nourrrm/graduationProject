Write-Output '>>> Waiting for GA Service (WindowsAzureGuestAgent) to start ...'
while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }
Write-Output '>>> Sysprepping VM ...'
if ( Test-Path $Env:SystemRoot\system32\Sysprep\unattend.xml ) {
    Remove-Item $Env:SystemRoot\system32\Sysprep\unattend.xml -Force
}
& $Env:SystemRoot\System32\Sysprep\Sysprep.exe /oobe /generalize /quiet /quit
while ($true) {
    $imageState = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State).ImageState
    Write-Output $imageState
    if ($imageState -eq 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') {
        Write-Output $imageState
        Write-Output "Het Syspreppen is geslaagd!"
        break
    }
    Start-Sleep -s 5
}
Write-Output '>>> Sysprep complete ...'