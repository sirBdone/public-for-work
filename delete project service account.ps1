<#
{
    "accountName": "projectServiceAccount"
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

# Delete the service account
Remove-ADUser -Identity $accountName -Confirm:$false

# Output result in JSON
$result = @{
    status = "success"
    message = "Service account $accountName has been deleted successfully."
}
$result | ConvertTo-Json
