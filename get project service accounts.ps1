<#
{
    "ou": "OU=Projects,DC=example,DC=com"
}

#>

param (
    [string]$inputFile
)

# Import the Active Directory module
Import-Module ActiveDirectory

# Read JSON input
$jsonInput = Get-Content -Raw -Path $inputFile | ConvertFrom-Json
$ou = $jsonInput.ou

# Get the service accounts in the specified OU
$serviceAccounts = Get-ADUser -Filter * -SearchBase $ou

# Output result in JSON
$result = @{
    status = "success"
    serviceAccounts = $serviceAccounts
}
$result | ConvertTo-Json
