function start-autoweb_generic {

    [cmdletbinding()]    
    param(
        $url = 'google.com',
        [ValidateSet("chrome")]
        [string]$browser = "chrome",
        [switch]$private = $false,
        [switch]$kiosk = $false,
        [switch]$TreatInsecureAsSecure = $false,
        [string]$search = $null
    )

    # Add-Type is typically done once per session. 
    # If this module is loaded multiple times, it can cause issues.
    # Consider moving this to a module manifest or a session startup script.
    try {
        Add-Type -Path "C:\selenium\WebDriver.dll" -ErrorAction Stop
    } catch {
        Write-Warning "Could not load WebDriver.dll. Ensure it's at 'C:\selenium\WebDriver.dll' and not already loaded. Error: $($_.Exception.Message)"
        return $null
    }

    # Set up browser options
    $browserOptions = $null
    $webDriverPath = "C:\Selenium" # Common path for WebDriver executables

    # Validate WebDriver executable exists
    $driverExecutable = "chromedriver.exe"
    $fullDriverPath = Join-Path -Path $webDriverPath -ChildPath $driverExecutable

    if (-not (Test-Path $fullDriverPath)) {
        Write-Error "WebDriver executable not found for 'chrome' at '$fullDriverPath'. Please download and place it there."
        return $null
    } else {
        Write-Host "Found WebDriver executable: $fullDriverPath"
    }

    # Set up Chrome options
    Write-Host "Preparing Chrome browser options..."
    $chromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
    
    $chromeArguments = New-Object System.Collections.Generic.List[string]
    if ($private) {
        $chromeArguments.Add("--incognito")
    } else {
        $chromeArguments.Add("--user-data-dir=$env:userprofile\appdata\local\google\chrome\user data")
    }
    if ($kiosk) {
        $chromeArguments.Add("--kiosk")
    }
    
    if ($TreatInsecureAsSecure) {
        $uri = New-Object System.Uri($url)
        $origin = "http://" + $uri.Host
        if ($uri.Port -ne 80 -and $uri.Port -ne -1) {
            $origin += ":" + $uri.Port
        }
        $chromeArguments.Add("--unsafely-treat-insecure-origin-as-secure=$origin")
        Write-Host "Treating insecure origin as secure: $origin"
    }
    
    if($chromeArguments.Count -gt 0){
        foreach ($arg in $chromeArguments) {
            $chromeOptions.AddArgument($arg)
        }
    }
    
    # Disable security options for downloads
    $chromeOptions.AddUserProfilePreference("download.default_directory", "$env:USERPROFILE\Downloads")
    $chromeOptions.AddUserProfilePreference("download.prompt_for_download", $false)
    $chromeOptions.AddUserProfilePreference("download.directory_upgrade", $true)
    $chromeOptions.AddUserProfilePreference("safebrowsing.enabled", $true)
    $chromeOptions.AddUserProfilePreference("safebrowsing.enhanced", $false)
    $chromeOptions.AddUserProfilePreference("safebrowsing.disable_download_protection", $false)
    $chromeOptions.AddUserProfilePreference("profile.default_content_setting_values.automatic_downloads", 1)
    
    $browserOptions = $chromeOptions

    # Ensure URL has https:// prefix if no protocol is specified
    if (!($url -match "^https?://.+")) {
        $url = "https://$url"
    }
    Write-Host "Target URL: $url"

    # Attempt to use existing global Chrome driver
    $currentGlobalDriver = $global:chromedriver

    # Only attempt to reuse an existing driver if it's not a private or kiosk session,
    # and a relevant global driver variable exists.
    if ($currentGlobalDriver -ne $null -and !$private -and !$kiosk) {
        Write-Host "Attempting to connect to existing Chrome driver for tab reuse."
        $global:driver = $currentGlobalDriver
        
        # Existing logic for connecting to an existing window/tab
        try {
            # Getting just the domain part for matching
            $uri = New-Object System.Uri($url)
            $searchword = $uri.Host
            Write-Host "Searchword for tab matching: $searchword"
            
            $desiredtab = $null
            # Iterate through window handles to find a matching URL
            foreach ($handle in $global:driver.WindowHandles) {
                try {
                    $global:driver.SwitchTo().Window($handle)
                    if ($global:driver.Url -like "*$searchword*") { 
                        $desiredtab = $handle
                        break # Found a match, no need to check further
                    }
                } catch {
                    Write-Verbose "Could not switch to window handle '$handle'. It might be closed. Error: $($_.Exception.Message)"
                }
            }

            if ($desiredtab -ne $null) {
                Write-Host "Switching to existing tab matching '$searchword'."
                $null = $global:driver.SwitchTo().window($desiredtab)
                $global:driver.Navigate().gotourl($url)
                return $global:driver # Return the active driver
            } else {
                Write-Host "No existing tab for '$searchword' found. Opening new tab."
                $global:driver.ExecuteScript("window.open('$($url)', '_blank');")
                # Wait a moment for the new tab to open and appear in window handles
                Start-Sleep -Milliseconds 500 
                $null = $global:driver.SwitchTo().window($global:driver.WindowHandles[-1])
                return $global:driver # Return the active driver
            }
        } catch {
            Write-Warning "Could not reuse existing Chrome driver/tab. Error: $($_.Exception.Message). Attempting to create new driver."
            $global:driver = $null # Clear $global:driver so a new one will be created
        }
    }

    # If no existing driver was found, if reuse failed, or if private/kiosk mode is requested, create a new one.
    if ($global:driver -eq $null) {
        Write-Host "Creating new Chrome driver instance..."
        try {
            $global:driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($webDriverPath, $browserOptions)

            # Maximize window if not in kiosk mode
            if (!$kiosk) {
                $global:driver.Manage().Window.Maximize()
            }
            
            $global:driver.Navigate().GoToUrl($url)
            # Set the global Chrome driver variable
            Set-Variable -Scope Global -Name "chromedriver" -Value $global:driver -Force
            Write-Host "Chrome browser launched successfully to $url"
            return $global:driver

        } catch {
            Write-Error "Failed to start Chrome driver. This is often due to WebDriver executable version mismatch with browser, or missing executable. Error: $($_.Exception.Message)"
            $global:driver = $null # Clear global driver on failure
            return $null
        }
    }
}

function close-chromedriver {get-process *chrome* | Stop-Process -Force}
new-alias -Name ccd -Value close-chromedriver -Force
new-alias saw -Value start-autoweb_generic -Force