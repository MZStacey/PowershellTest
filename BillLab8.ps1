<#
.SYNOPSIS
Tests a connection to CloudFlare DNS

.DESCRIPTION
This command will test a single computer's or multiple computers' Internet connection to CloudFlare's One.One.One.One DNS Server  

.PARAMETER Computername
The computer name, or names, to query.  No default.  This is a mandatory parameter that will prompt the user for input.
.PARAMETER Path
Specifies a path of one or more locations.  The default location is the that users currently loggin in home directory.
.PARAMETER Output
Specifies the destination of output when script is run.  There are three output options.  They are Host, Text or CSV.  The default value is Host.
	- Host (screen)
	- Text (.txt file)
	- CSV (.csv file)
File outputs are saved to the user's home directory.  The default destination is host.
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$True)]
	[string[]]$Computername,
	[Parameter(Mandatory=$False)]
	[string]$Path = "$Env:USERPROFILE",
	[Parameter(Mandatory=$False)]
	[string[]]$Output	
)
Clear-Host
Set-Location $Path
$DateTime = Get-Date

#Creates a new session to the remote computer(s)
$Session = New-PSSession -computername $Computername

Write-Verbose "Connecting to $Computername ...."

#Remotely runs Test-NetConnection to 1.1.1.1 on target computer (s) as a background job
invoke-command -command {Test-NetConnection -Computername one.one.one.one -InformationLevel Detailed} -session $Session -asjob  -jobname RemTestNet

Write-Verbose "Testing connection to One.One.One.One on $Computername ...."

#Pauses script processing to allow Test-NetConnection to complete
Start-sleep -Seconds 10

#Receives the job results
Write-Verbose "Receiving test results"
Receive-Job -name RemTestNet | Out-file .\JobResults.txt

#Creates a test file containing the name of the computer being tested, the date/time, and the job output
Write-Verbose "Generating results file"
Add-Content .\RemTestNet.txt -value "Computer Tested: $Computername"
Add-Content .\RemTestNet.txt -value "Date/Time Tested: $Datetime"
Add-Content .\RemTestNet.txt -value (Get-Content -path .\JobResults.txt)

Write-Verbose "Opening Results"
notepad .\RemTestNet.txt

#Closes the session to the remote computer(s) and deletes the JobResults.txt file
Remove-PSSession -session $Session
Remove-Item .\JobResults.txt

Write-Verbose "Finished Running Test"

