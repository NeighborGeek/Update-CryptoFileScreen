#requires -Version 1.0
function Update-CryptoFileScreen 
{
    # Email Sever Settings
    $SMTPServer = '<YOURMAILSERVER>'
    $SMTPFrom = "$env:computername@<YOURDOMAIN>"
    $SMTPTo = '<YOURALERTEMAIL>'
    $AdminEmail = '<YOURADMINEMAIL>'
  
    # Get Ransomware Known File Types
    $CryptoExtensions = Get-Content -Path '<YOURUNCPATH>\FileExtensions.txt'
    $Exclusions = Get-Content -Path '<YOURUNCPATH>\Exclusions.txt'
  
    # Import Server Manager PS Module
    Import-Module -Name ServerManager
  
    # Install FSRM Role if required
    if ((Get-WindowsFeature -Name FS-Resource-Manager).InstallState -ne 'Installed')
    {
        $null = Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools
    }
  
    # Install Crypto Extension Monitoring / Blocking
    if ((Get-FSRMFileScreen).Description -notcontains 'Crypto Extension Monitoring')
    {
        # Set FSRM Email Settings
        Set-FSRMSetting -AdminEmailAddress $AdminEmail -SMTPServer $SMTPServer -FromEmailAddress $SMTPFrom
    
        # Create FSRM File Group
        if ($Exclusions) 
        {
            $null = New-FSRMFileGroup -name 'CryptoExtensions' -IncludePattern $CryptoExtensions -excludepattern $Exclusions -Description 'Crypto Extension Detection'
        }
        else 
        {
            $null = New-FSRMFileGroup -name 'CryptoExtensions' -IncludePattern $CryptoExtensions -Description 'Crypto Extension Detection'
        }
    
        # Set FRSM Notification Message & Scan Interval
        $Notification = New-FSRMAction -Type Email -Subject "Crypto File Activity Detected - $env:computername" -Body 'User [Source IO Owner] attempted to save [Source File Path] to [File Screen Path] on the [Server] server. This file is in violation of the [Violated File Group] file group. This file could be a marker for malware infection, and should be investigated immediately.' -RunLimitInterval 30 -MailTo $SMTPTo
    
        # Create FSRM Template
        $null = New-FsrmFileScreenTemplate -Name CryptoExtensions -Description 'Known CryptoLocker File Extesions' -IncludeGroup CryptoExtensions -Active -Notification $Notification
    
        # Build Drive Lists
        $Drives = Get-WmiObject -Class Win32_LogicalDisk -Filter DriveType=3 | Select-Object -ExpandProperty DeviceID
    
        # Apply FSRM Screen
        foreach ($Drive in $Drives)
        {
            $null = New-FSRMFileScreen -Path $Drive -Active -Description 'Crypto Extension Monitoring' -Template CryptoExtensions -Notification $Notification
        }
    }
  
    # Update Cyrpto File Extensions 
    if ((Get-FSRMFileScreen).Description -contains 'Crypto Extension Monitoring')
    {
        # Update File Screen
        if ($Exclusions) 
        {
            Set-FSRMFileGroup -Name CryptoExtensions -IncludePattern $CryptoExtensions -excludepattern $Exclusions
        }
        else 
        {
            Set-FSRMFileGroup -Name CryptoExtensions -IncludePattern $CryptoExtensions
        }
    }
  
    # Check for FSRM File Screen
    $CryptoScreen = Get-FSRMFileScreen | Where-Object -FilterScript {
        $_.Description -eq 'Crypto Extension Monitoring'
    }
  
    if ($CryptoScreen -gt $null)
    {
        $CryptoCICompliant = $true
    }
    else
    {
        $CryptoCICompliant = $false
    }
    Return $CryptoCICompliant
}
Update-CryptoFileScreen
