<#
{
    "groupName": "ProjectGroup"
}
#>

param (
    [string]$inputFile
)

# Import the Active Directory module
Import-Module ActiveDirectory

# Read JSON input
$jsonInput = Get-Content -Raw -Path $inputFile | ConvertFrom-Json
$groupName = $jsonInput.groupName

# Get the AD group
$group = Get-ADGroup -Identity $groupName

# Output result in JSON
$result = @{
    status = "success"
    group = $group
}
$result | ConvertTo-Json
