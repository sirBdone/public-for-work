# Define your RHEL machine's hostname and credentials
$hostname = "hostname"   # replace with your RHEL machine hostname or IP
$username = "username"   # replace with your RHEL machine's username
$password = ConvertTo-SecureString "password" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $password)

# Start the SSH session to the RHEL machine
$session = New-PSSession -HostName $hostname -UserName $username -Credential $cred

# Fetch all repo files except redhat.repo
$fetchRepoFilesScript = @"
#!/bin/bash
find /etc/yum.repos.d/ -type f -name "*.repo" ! -name "redhat.repo"
"@

# Get list of repos from remote machine
$repoFiles = Invoke-Command -Session $session -ScriptBlock {
    param ($script)
    bash -c "$script"
} -ArgumentList $fetchRepoFilesScript

# Display repo files to choose from
$selectedRepos = $repoFiles | Out-GridView -Title "Select Repositories to Disable" -PassThru

if ($selectedRepos) {
    # Script to disable all instances of enabled=1 in selected repo files
    $disableReposScript = @"
#!/bin/bash
for repoFile in $selectedRepos; do
  sudo sed -i 's/enabled=1/enabled=0/g' "\$repoFile"
done
"@

    # Execute the script remotely
    Invoke-Command -Session $session -ScriptBlock {
        param ($script)
        bash -c "$script"
    } -ArgumentList $disableReposScript
}

# Close the session
Remove-PSSession -Session $session
