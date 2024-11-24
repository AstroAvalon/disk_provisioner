# Logging Function
function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Write-Output $logEntry
    Add-Content -Path "C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\execution.log" -Value $logEntry
}

# Error Handling
$ErrorActionPreference = "Stop"

# Extract ZIP
try {
    Log "Extracting scripts and files..."
    $zipPath = "C:\CustomScript\ODT.zip"
    $extractPath = "C:\CustomScript\Extracted"
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    Log "Extraction complete."
} catch {
    Log "Failed to extract ZIP file: $_"
    exit 1
}

# Run Provision Disks Script
try {
    Log "Starting disk provisioning..."
    $diskScript = Join-Path $extractPath "provision_disks.ps1"
    powershell.exe -ExecutionPolicy Unrestricted -File $diskScript
    Log "Disk provisioning completed successfully."
} catch {
    Log "Disk provisioning failed: $_"
    exit 1
}

# Run Install Office Script
try {
    Log "Starting Office installation..."
    $officeScript = Join-Path $extractPath "install_office.ps1"
    powershell.exe -ExecutionPolicy Unrestricted -File $officeScript
    Log "Office installation completed successfully."
} catch {
    Log "Office installation failed: $_"
    exit 1
}

# Run Software Installation Script
try {
    Log "Starting software installation..."
    $softwareScript = Join-Path $extractPath "install_software.ps1"
    powershell.exe -ExecutionPolicy Unrestricted -File $softwareScript
    Log "Software installation completed successfully."
} catch {
    Log "Software installation failed: $_"
    exit 1
}

Log "All tasks completed successfully."
exit 0
