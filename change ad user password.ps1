<#
{
    "username": "johndoe",
    "newPassword": "NewP@ssw0rd!"
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
$newPassword = $jsonInput.newPassword

# Reset the user's password
Set-ADAccountPassword -Identity $userAccount -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force) -Reset

# Output result in JSON
$result = @{
    status = "success"
    message = "Password for $userAccount has been reset successfully."
}
$result | ConvertTo-Json
