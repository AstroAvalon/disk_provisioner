# Install Office using ODT
$ErrorActionPreference = "Stop"
Start-Process -FilePath "C:\\CustomScript\\Extracted\\ODT\\setup.exe" -ArgumentList "/configure C:\\CustomScript\\Extracted\\ODT\\configuration.xml" -Wait
Write-Output "Office installation completed."
