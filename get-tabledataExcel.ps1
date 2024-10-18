# Function to extract table data into a PSCustomObject array, with Shadow DOM handling
function Get-TableData {
    param(
        [Parameter(Mandatory = $true)]
        [object]$table,
        [object]$chromedriver
    )

    # Helper function to access elements in Shadow DOM if needed
    function Get-ShadowRootElements {
        param(
            [Parameter(Mandatory = $true)]
            [object]$hostElement,
            [string]$tagName
        )

        # Access the shadow root of the host element via JavaScript
        $shadowRoot = $chromedriver.ExecuteScript("return arguments[0].shadowRoot", $hostElement)

        if ($shadowRoot -ne $null) {
            return $shadowRoot.FindElementsByTagName($tagName)
        } else {
            return @() # Return empty array if shadowRoot not found
        }
    }

    # Get the <thead> and <tbody> sections
    $thead = $table.FindElementByTagName('thead')
    $tbody = $table.FindElementByTagName('tbody')

    # Extract headers from <thead>, including handling for shadow DOM
    $headers = @()
    if ($thead) {
        # First try normal access to the header elements
        $headerElements = $thead.FindElementsByTagName('th')

        # Check if the headers might be inside a shadow DOM and text is blank
        if ($headerElements[0].Text -eq "") {
            Write-Host "Headers are inside a shadow DOM, accessing shadow root..."
            $headerElements = Get-ShadowRootElements -hostElement $thead -tagName 'th'
        }

        foreach ($header in $headerElements) {
            $headers += $header.Text.Trim() # Collect header names
        }
    }

    # If no headers found in <thead>, fallback to first row in <tbody> as headers
    if (-not $headers) {
        Write-Host "No headers in <thead>, falling back to first row in <tbody>..."
        $firstRow = $tbody.FindElementByTagName('tr')
        $headerElements = $firstRow.FindElementsByTagName('td')

        if ($headerElements[0].Text -eq "") {
            Write-Host "Row is inside a shadow DOM, accessing shadow root..."
            $headerElements = Get-ShadowRootElements -hostElement $firstRow -tagName 'td'
        }

        foreach ($header in $headerElements) {
            $headers += $header.Text.Trim()
        }
    }

    # Collect table data from <tbody>
    $rows = $tbody.FindElementsByTagName('tr')
    $tableData = @()

    foreach ($row in $rows) {
        $cells = $row.FindElementsByTagName('td')

        # Handle Shadow DOM for table rows if necessary
        if ($cells[0].Text -eq "") {
            Write-Host "Table cells are inside a shadow DOM, accessing shadow root..."
            $cells = Get-ShadowRootElements -hostElement $row -tagName 'td'
        }

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
# And assuming $chromedriver is your Selenium WebDriver instance

$tableData = Get-TableData -table $table -chromedriver $chromedriver

# Export the table data to an Excel file
$tableData | Export-Excel -Path "C:\path\to\exported_table.xlsx" -Now
