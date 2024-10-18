# Function to extract table data into a PSCustomObject array
function Get-TableData {
    param(
        [Parameter(Mandatory = $true)]
        [object]$table
    )

    # Get the <thead> and <tbody> sections
    $thead = $table.FindElementByTagName('thead')
    $tbody = $table.FindElementByTagName('tbody')

    # Extract headers from <thead>
    $headers = @()
    if ($thead) {
        $headerElements = $thead.FindElementsByTagName('th')
        foreach ($header in $headerElements) {
            $headers += $header.Text.Trim() # Collect header names
        }
    }

    # If no headers found in <thead>, fallback to first row in <tbody> as headers
    if (-not $headers) {
        $firstRow = $tbody.FindElementByTagName('tr')
        $headerElements = $firstRow.FindElementsByTagName('td')
        foreach ($header in $headerElements) {
            $headers += $header.Text.Trim()
        }
    }

    # Collect table data from <tbody>
    $rows = $tbody.FindElementsByTagName('tr')
    $tableData = @()

    foreach ($row in $rows) {
        $cells = $row.FindElementsByTagName('td')

        # Only process rows that match the number of headers
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

# Assuming $table is already set (e.g., $table = $chromedriver.FindElementByTagName('table'))
$tableData = Get-TableData -table $table

# Export the table data to an Excel file
$tableData | Export-Excel -Path "C:\path\to\exported_table.xlsx" -Now
