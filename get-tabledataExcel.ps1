# Ensure you have the ImportExcel module installed
# Install-Module -Name ImportExcel

# Assuming $chromedriver is your initialized Selenium WebDriver object
#$table = $chromedriver.FindElementByTagName('table')

# Function to extract table data into a PSCustomObject array
function Get-TableData {
    param(
        [Parameter(Mandatory = $true)]
        [object]$table
    )

    # Get the headers (assuming 'th' tags are present)
    $headers = @()
    $headerElements = $table.FindElementsByTagName('th')
    foreach ($header in $headerElements) {
        $headers += $header.Text.Trim() # Collect header names
    }

    # If there are no 'th' elements, fall back to first row's 'td' as headers
    if (-not $headers) {
        $firstRow = $table.FindElementByTagName('tr')
        $headerElements = $firstRow.FindElementsByTagName('td')
        foreach ($header in $headerElements) {
            $headers += $header.Text.Trim()
        }
    }

    # Collect table data
    $rows = $table.FindElementsByTagName('tr')
    $tableData = @()

    foreach ($row in $rows) {
        $cells = $row.FindElementsByTagName('td')
        if ($cells.Count -eq $headers.Count) {
            $dataObject = [PSCustomObject]@{}

            for ($i = 0; $i -lt $cells.Count; $i++) {
                $dataObject | Add-Member -MemberType NoteProperty -Name $headers[$i] -Value $cells[$i].Text.Trim()
            }

            $tableData += $dataObject
        }
    }

    return $tableData
}

# Extract the table data
$tableData = Get-TableData -table $table

# Export the table data to an Excel file
$tableData | Export-Excel -Path "C:\path\to\exported_table.xlsx" -Now
