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
    Log "Executing disk_provision.ps1..."
    & "$ExtractPath\disk_provision.ps1" -LogFile "$ExtractPath\Logs\disk_provision.log"

    # Add additional script calls here if needed
    Log "Bootstrap process completed successfully."
} catch {
    Log "Error: $_"
    exit 1
}

exit 0
