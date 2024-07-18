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

# Enable the user account
Enable-ADAccount -Identity $userAccount

# Output result in JSON
$result = @{
    status = "success"
    message = "Account $userAccount has been enabled successfully."
}
$result | ConvertTo-Json
