<#
.SYNOPSIS
Tests a connection to CloudFlare DNS

.DESCRIPTION
This command will test a single computer's or multiple computers' Internet connection to CloudFlare's One.One.One.One DNS Server  

.PARAMETER Computername
The computer name, or names, to query.  No default.  This is a mandatory parameter that will prompt the user for input.
.PARAMETER Path
Specifies a path of one or more locations.  The default location is the that users currently loggin in home directory.  
#>
[CmdletBinding()]


Param (
[Parameter(Mandatory=$True)]
[string]$Computername,
[string]$Path = [Environment]::GetEnvironmentVariable('USERPROFILE')
)

$Computername = '192.168.1.68'
$Path = 'C:\Powershell Test'
$Session = New-PSSession -computername $Computername



#Creating a variable that display the current date and time
$Datetime = Get-Date

Clear-Host
Set-Location $Path

Write-Verbose "Connecting to the computer $Computername being tested"

#Creates a new session to the remote computer
$Session = New-PSSession -computername $Computername

#Remotely runs Test-NetConnection to 1.1.1.1 on target computer(s) as a background job
invoke-command -command {Test-NetConnection -Computername one.one.one.one -InformationLevel Detailed} -session $Session -asjob  -jobname RemTestNet




Write-Verbose "Running the test on the remote computer $Computername"


#Pauses script processing to allow Test-NetConnection to complete
Start-sleep -seconds 10


Write-Verbose "Receiving Test Results"


#Receives the job results, saves them as a text file, and opens notepad to display the results


Write-Verbose "Generating Test Results"

Receive-Job -name RemTestNet | Out-file .\JobResults.txt

Add-Content -Path .\RemTestNet.txt -value (Get-Content -Path .\JobResults.txt)
Add-Content -Path .\RemTestNet.txt -value "Date and time test was run $Datetime"
Add-Content -Path .\RemTestNet.txt -value "This was the computer tested $Computername"


Write-Verbose "Opening Results"

notepad Test-CloudFlare.txt

Write-Verbose "Finished Running Test"

remove-pssession -session $Session