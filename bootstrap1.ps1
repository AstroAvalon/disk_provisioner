# Parameters
param(
    [string]$ZipUri = "<STORAGE_ACCOUNT_BLOB_SAS_URL_TO_ZIP>", # Replace with the SAS URL to the ZIP file
    [string]$DownloadPath = "C:\CustomScript\PDA.zip",
    [string]$ExtractPath = "C:\CustomScript\Extracted",
    [string]$LogFile = "C:\CustomScript\Logs\bootstrap.log"
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
    # Ensure directories exist
    if (-Not (Test-Path $ExtractPath)) {
        New-Item -ItemType Directory -Path $ExtractPath | Out-Null
    }
    if (-Not (Test-Path (Split-Path $LogFile))) {
        New-Item -ItemType Directory -Path (Split-Path $LogFile) | Out-Null
    }

    # Download ZIP file
    Log "Downloading ZIP file from $ZipUri to $DownloadPath..."
    Invoke-WebRequest -Uri $ZipUri -OutFile $DownloadPath

    # Extract ZIP file
    Log "Extracting ZIP file $DownloadPath to $ExtractPath..."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($DownloadPath, $ExtractPath)

    # Execute provision_disks.ps1
    try {
        Log "Executing disk_provision.ps1..."
        & "$ExtractPath\disk_provision.ps1" -LogFile $LogFile
        Log "disk_provision.ps1 completed successfully."
    } catch {
        Log "Error during disk_provision.ps1: $_"
    }

    # Install Office
    try {
        Log "Executing install_office.ps1..."
        & "$ExtractPath\install_office.ps1" -LogFile $LogFile
        Log "install_office.ps1 completed successfully."
    } catch {
        Log "Error during install_office.ps1: $_"
    }

    # Install UiPath
    try {
        Log "Executing install_uipath.ps1..."
        & "$ExtractPath\install_uipath.ps1" -LogFile $LogFile
        Log "install_uipath.ps1 completed successfully."
    } catch {
        Log "Error during install_uipath.ps1: $_"
    }

    # Add additional script calls here if needed
    Log "Bootstrap process completed successfully."
} catch {
    Log "Critical error in bootstrap process: $_"
    exit 1
}

exit 0
