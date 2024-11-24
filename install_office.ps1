# Parameters
param(
    [string]$LogFile = "C:\CustomScript\Logs\bootstrap.log" # Default log file location if not provided
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

try {
    Log "Starting Office installation process."

    # Check if Office is already installed
    $officeInstalled = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {
        $_.DisplayName -like "*Microsoft 365*" -or $_.DisplayName -like "*Office*"
    }

    if ($officeInstalled) {
        Log "Office is already installed. Skipping installation."
        exit 0
    }

    # Define paths
    $setupExe = "C:\CustomScript\Extracted\ODT\setup.exe"
    $configXml = "C:\CustomScript\Extracted\ODT\config.xml"

    # Validate file paths
    if (-Not (Test-Path $setupExe)) {
        Log "Error: Setup.exe not found at $setupExe."
        throw "Setup.exe not found."
    }

    if (-Not (Test-Path $configXml)) {
        Log "Error: Configuration.xml not found at $configXml."
        throw "Configuration.xml not found."
    }

    # Start Office installation
    Log "Running Office setup.exe with configuration.xml..."
    Start-Process -FilePath $setupExe -ArgumentList "/configure $configXml" -Wait -NoNewWindow

    # Verify installation
    $officeInstalledPost = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {
        $_.DisplayName -like "*Microsoft 365*" -or $_.DisplayName -like "*Office*"
    }

    if ($officeInstalledPost) {
        Log "Office installation completed successfully."
    } else {
        Log "Error: Office installation failed."
        throw "Office installation failed."
    }

} catch {
    Log "Error during Office installation: $_"
    exit 1
}

Log "Office installation script execution completed."
exit 0
