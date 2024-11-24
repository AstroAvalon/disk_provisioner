# Parameters
param(
    [string]$FileSystem = "NTFS",
    [string]$LogFile = "C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\disk_initialization.log"
)

# Logging Function
function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Write-Output $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

# Error Handling
$ErrorActionPreference = "Stop"

# Get all disks that are uninitialized
$disks = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' }

# Exit gracefully if no disks are found
if ($disks.Count -eq 0) {
    Log "No uninitialized disks found. Exiting."
    exit 0
}

foreach ($disk in $disks) {
    try {
        # Check if disk is online
        if ($disk.OperationalStatus -ne 'Online') {
            Log "Disk $($disk.Number) is not online. Bringing it online..."
            Set-Disk -Number $disk.Number -IsOffline $false -IsReadOnly $false
        }

        # Initialize the disk
        Log "Initializing Disk $($disk.Number)..."
        Initialize-Disk -Number $disk.Number -PartitionStyle GPT | Out-Null

        # Retrieve the partition information
        Log "Creating partition on Disk $($disk.Number)..."
        $partition = New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter

        # Retrieve the drive letter of the new partition
        $driveLetter = ($partition | Get-Partition | Get-Volume).DriveLetter

        # Format the partition
        Log "Formatting partition on Disk $($disk.Number) with $FileSystem..."
        Format-Volume -FileSystem $FileSystem -DriveLetter $driveLetter -Confirm:$false | Out-Null

        Log "Disk $($disk.Number) initialized, formatted, and mounted to drive $driveLetter."
    } catch {
        Log "Failed to process Disk $($disk.Number): $_"
        continue
    }
}

Log "Disk initialization and mounting process complete."
exit 0