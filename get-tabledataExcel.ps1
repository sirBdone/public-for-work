# Function to extract table data into a PSCustomObject array using JavaScript execution to access text
function Get-TableData {
    param(
        [Parameter(Mandatory = $true)]
        [object]$chromedriver,  # Selenium WebDriver instance
        [Parameter(Mandatory = $true)]
        [object]$table          # Table DOM object inside iframe
    )

    # JavaScript code to extract text from table rows and cells
    $jsScript = @"
        let table = arguments[0];
        let headers = Array.from(table.querySelectorAll('thead th')).map(th => th.textContent.trim());
        let rows = Array.from(table.querySelectorAll('tbody tr')).map(row => {
            let cells = Array.from(row.querySelectorAll('td')).map(td => td.textContent.trim());
            return cells;
        });
        return { headers: headers, rows: rows };
"@

    # Execute the JavaScript to retrieve table headers and rows
    $tableData = $chromedriver.ExecuteScript($jsScript, $table)

    # Create an array to store PSCustomObject instances for each row
    $psTableData = @()

    # Process headers and rows
    $headers = $tableData.headers
    foreach ($row in $tableData.rows) {
        $dataObject = [PSCustomObject]@{}

        for ($i = 0; $i -lt $row.Count; $i++) {
            $dataObject | Add-Member -MemberType NoteProperty -Name $headers[$i] -Value $row[$i]
        }

        $psTableData += $dataObject
    }

    return $psTableData
}

# Assuming $table is already set (e.g., $table = $chromedriver.FindElementByTagName('table'))
# And assuming $chromedriver is your Selenium WebDriver instance

$tableData = Get-TableData -chromedriver $chromedriver -table $table

# Export the table data to an Excel file
$tableData | Export-Excel -Path "C:\path\to\exported_table.xlsx" -Now
