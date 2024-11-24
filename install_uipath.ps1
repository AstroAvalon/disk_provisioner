# Parameters
param(
    [string]$InstallerPath = "C:\CustomScript\Extracted\UiPathStudio.msi", # Path to the UiPath MSI
    [string]$LogFile = "C:\CustomScript\Logs\bootstrap.log"               # Unified log file
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
    Log "Starting UiPath installation process."

    # Check if UiPath is already installed
    Log "Checking if UiPath is installed..."
    $uipathKeyPattern = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $uipathInstalled = Get-ItemProperty -Path $uipathKeyPattern | Where-Object { $_.DisplayName -like "*UiPath*" }

    if ($uipathInstalled) {
        Log "UiPath is already installed. Version: $($uipathInstalled.DisplayVersion). Exiting installation process."
        exit 0
    }

    # Validate Installer Path
    if (-Not (Test-Path $InstallerPath)) {
        Log "Error: UiPath installer not found at $InstallerPath."
        throw "Installer not found."
    }

    # Install UiPath silently
    Log "UiPath is not installed. Starting installation from $InstallerPath..."
    Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /quiet /norestart" -Wait -NoNewWindow

    # Verify installation
    $uipathInstalledPost = Get-ItemProperty -Path $uipathKeyPattern | Where-Object { $_.DisplayName -like "*UiPath*" }
    if ($uipathInstalledPost) {
        Log "UiPath installation completed successfully. Version: $($uipathInstalledPost.DisplayVersion)."
    } else {
        Log "Error: UiPath installation did not complete successfully."
        throw "UiPath installation verification failed."
    }

} catch {
    Log "Error during UiPath installation: $_"
    exit 1
}

Log "UiPath installation process completed successfully."
exit 0
