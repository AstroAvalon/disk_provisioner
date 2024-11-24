# Parameters
param(
    [string]$InstallerPath = "C:\CustomScript\Extracted\UiPathStudio.msi",
    [string]$LogFile = "C:\CustomScript\Logs\install_uipath.log"
)

# Logging function
function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Write-Output $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

# Error handling
$ErrorActionPreference = "Stop"

# Ensure log file directory exists
if (-Not (Test-Path (Split-Path $LogFile))) {
    New-Item -ItemType Directory -Path (Split-Path $LogFile) | Out-Null
}

try {
    # Check if UiPath is already installed
    Log "Checking if UiPath is installed..."
    $uipathKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\UiPath"
    if (Test-Path $uipathKey) {
        Log "UiPath is already installed. Exiting."
        exit 0
    }

    # Install UiPath silently
    Log "UiPath is not installed. Starting installation..."
    Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /quiet /norestart" -Wait -NoNewWindow

    Log "UiPath installation completed successfully."
} catch {
    Log "Error during UiPath installation: $_"
    exit 1
}

Log "UiPath installation process complete."
exit 0
