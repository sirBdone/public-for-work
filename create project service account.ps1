<#
{
    "accountName": "projectServiceAccount",
    "ou": "OU=Projects,DC=example,DC=com",
    "password": "Serv1ceP@ssw0rd!"
}

#>

param (
    [string]$inputFile
)

# Import the Active Directory module
Import-Module ActiveDirectory

# Read JSON input
$jsonInput = Get-Content -Raw -Path $inputFile | ConvertFrom-Json
$accountName = $jsonInput.accountName
$ou = $jsonInput.ou
$password = $jsonInput.password

# Create the service account
New-ADUser -Name $accountName -SamAccountName $accountName -Path $ou -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -Enabled $true

# Output result in JSON
$result = @{
    status = "success"
    message = "Service account $accountName has been created successfully."
}
$result | ConvertTo-Json
