# Provision and format uninitialized disks
$ErrorActionPreference = "Stop"
$disks = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' }

foreach ($disk in $disks) {
    Initialize-Disk -Number $disk.Number -PartitionStyle GPT
    $partition = New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter
    Format-Volume -DriveLetter $partition.DriveLetter -FileSystem NTFS -Confirm:$false
    Write-Output "Disk $($disk.Number) provisioned and formatted."
}
