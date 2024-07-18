<#
{
    "username": "johndoe"
}

#>

param (
    [string]$inputFile
)

# Import the Active Directory module
Import-Module ActiveDirectory

# Read JSON input
$jsonInput = Get-Content -Raw -Path $inputFile | ConvertFrom-Json
$userAccount = $jsonInput.username

# Disable the user account
Disable-ADAccount -Identity $userAccount

# Output result in JSON
$result = @{
    status = "success"
    message = "Account $userAccount has been disabled successfully."
}
$result | ConvertTo-Json
