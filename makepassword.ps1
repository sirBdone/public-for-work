[cmdletbinding()]
param([int]$length = 12)  # Default to 12

# Character set
$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$"

# Adjust length to be between 4 and 65
if ($length -lt 4) { $length = 4 }
if ($length -gt 65) { $length = 65 }

# Start with one of each required type
$password = @(
    "abcdefghijklmnopqrstuvwxyz"[(Get-Random -Minimum 0 -Maximum 26)]
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[(Get-Random -Minimum 0 -Maximum 26)]
    "0123456789"[(Get-Random -Minimum 0 -Maximum 10)]
    "!@#$"[(Get-Random -Minimum 0 -Maximum 4)]
)

# Fill remaining length
for ($i = 4; $i -lt $length; $i++) {
    $password += $chars[(Get-Random -Minimum 0 -Maximum 65)]
}

# Shuffle and join
$password = ($password | Get-Random -Count $password.Length) -join ""

return $password