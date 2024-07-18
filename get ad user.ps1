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

# Get the AD user
$user = Get-ADUser -Identity $userAccount -Properties *

# Output result in JSON
$result = @{
    status = "success"
    user = $user
}
$result | ConvertTo-Json
