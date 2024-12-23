$computers = @("Computer1", "Computer2", "Computer3")

# Initialize global arrays
$global:breakglass = @()
$global:nobreakglass = @()

foreach ($computer in $computers) {
    try {
        # Invoke quser on the remote computer
        $quserResult = Invoke-Command -ComputerName $computer -ScriptBlock {
            quser | ForEach-Object {
                $_ -replace '\s+', ',' | ConvertFrom-Csv -Delimiter ','
            }
        } -ErrorAction Stop

        if ($quserResult) {
            # Check active sessions excluding the user invoking the command
            $currentUser = $env:USERNAME
            $activeSessions = $quserResult | Where-Object { $_.STATE -eq "Active" -and $_.USERNAME -ne $currentUser }

            if ($activeSessions.Count -eq 0) {
                # No active connections found; add to breakglass array
                $global:breakglass += $computer
            } else {
                # Active connections found; add to nobreakglass array
                $global:nobreakglass += [PSCustomObject]@{
                    ComputerName = $computer
                    ActiveUser   = $activeSessions.USERNAME -join ", "
                }
            }
        } else {
            # No sessions found; add to breakglass array
            $global:breakglass += $computer
        }
    } catch {
        # Cannot connect; add to nobreakglass array with error message
        $global:nobreakglass += [PSCustomObject]@{
            ComputerName = $computer
            ActiveUser   = "Connection Failed"
        }
    }
}

# Output the results
Write-Host "Breakglass computers:" -ForegroundColor Green
$global:breakglass | ForEach-Object { Write-Host $_ }

Write-Host "\nNo Breakglass computers with active connections:" -ForegroundColor Red
$global:nobreakglass | Format-Table -AutoSize
