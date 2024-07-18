<#
{
    "projectName": "OU=ProjectName,DC=example,DC=com"
}

#>

param (
    [string]$inputFile
)

# Import the Active Directory module
Import-Module ActiveDirectory

# Read JSON input
$jsonInput = Get-Content -Raw -Path $inputFile | ConvertFrom-Json
$projectName = $jsonInput.projectName

# Delete the project (assuming the project is an organizational unit)
Remove-ADOrganizationalUnit -Identity $projectName -Recursive -Confirm:$false

# Output result in JSON
$result = @{
    status = "success"
    message = "Project $projectName has been deleted successfully."
}
$result | ConvertTo-Json
