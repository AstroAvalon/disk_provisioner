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
    Log "Starting disk provisioning process."

    # Get all uninitialized disks
    $disks = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' }

    if ($disks.Count -eq 0) {
        Log "No uninitialized disks found. Exiting."
        exit 0
    }

    foreach ($disk in $disks) {
        try {
            # Log initial disk details
            Log "Processing Disk $($disk.Number):"
            Log "  - Size: $([math]::Round($disk.Size / 1GB, 2)) GB"
            Log "  - Status: $($disk.OperationalStatus)"

            # Initialize the disk
            Log "  Initializing Disk $($disk.Number)..."
            Initialize-Disk -Number $disk.Number -PartitionStyle GPT

            # Create a new partition using all available space
            Log "  Creating partition on Disk $($disk.Number)..."
            $partition = New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter

            # Format the partition
            $volumeLabel = "DataDisk_$($disk.Number)"
            Log "  Formatting partition on Disk $($disk.Number) with NTFS and label '$volumeLabel'..."
            Format-Volume -DriveLetter $partition.DriveLetter -FileSystem NTFS -NewFileSystemLabel $volumeLabel -Confirm:$false

            # Log post-formatting details
            Log "  Disk $($disk.Number) provisioned successfully:"
            Log "    - Drive Letter: $($partition.DriveLetter)"
            Log "    - Volume Label: $volumeLabel"
            Log "    - Partition Size: $([math]::Round($partition.Size / 1GB, 2)) GB"

        } catch {
            Log "  Failed to process Disk $($disk.Number): $_"
            continue
        }
    }

    Log "Disk provisioning process completed successfully."
} catch {
    Log "Error during disk provisioning: $_"
    exit 1
}

Log "Disk provisioning script execution completed."
exit 0
