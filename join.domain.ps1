# Parameters
param(
    [string]$DomainName = "<YOUR_DOMAIN_NAME>", # Replace with your AD domain
    [string]$OUPath = "OU=CustomOU,DC=example,DC=com", # Replace with your OU path
    [string]$KeyVaultUri = "<YOUR_KEY_VAULT_URI>", # Replace with your Key Vault URI
    [string]$UsernameSecretName = "ADJoinUsername", # Name of the secret storing the username
    [string]$PasswordSecretName = "ADJoinPassword", # Name of the secret storing the password
    [string]$LogFile = "C:\CustomScript\Logs\join_domain.log"
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
    # Ensure log file directory exists
    if (-Not (Test-Path (Split-Path $LogFile))) {
        New-Item -ItemType Directory -Path (Split-Path $LogFile) | Out-Null
    }

    # Check if already on the domain
    Log "Checking if the server is already joined to the domain..."
    $computerDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
    if ($computerDomain -eq $DomainName) {
        Log "Server is already joined to the domain $DomainName. Exiting."
        exit 0
    }

    # Retrieve credentials from Key Vault
    Log "Retrieving credentials from Azure Key Vault..."
    $username = (Invoke-RestMethod -Uri "$KeyVaultUri/secrets/$UsernameSecretName?api-version=7.2" -Headers @{ Authorization = "Bearer $(Get-AzAccessToken -Resource https://vault.azure.net | Select-Object -ExpandProperty Token)" }).value
    $password = (Invoke-RestMethod -Uri "$KeyVaultUri/secrets/$PasswordSecretName?api-version=7.2" -Headers @{ Authorization = "Bearer $(Get-AzAccessToken -Resource https://vault.azure.net | Select-Object -ExpandProperty Token)" }).value
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

    # Join the domain
    Log "Joining the domain $DomainName with OU path $OUPath..."
    Add-Computer -DomainName $DomainName -Credential $credential -OUPath $OUPath -Force -ErrorAction Stop
    Log "Successfully joined the domain $DomainName."

    # Restart to complete the process
    Log "Restarting the server to complete the domain join process..."
    Restart-Computer -Force
} catch {
    Log "Error during domain join process: $_"
    exit 1
}

Log "Domain join process completed."
exit 0
