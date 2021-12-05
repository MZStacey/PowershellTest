function Test-CloudFlare3 {
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
    
    .NOTES
        Author:  Michael Stacey
        Last Edit: 2021 Nov 12
        Version 192.4 Three hundred and seventy-fifth Trial for Initial Release of Test-CloudFlare
                11/12/2021 - Instituted a Try catch to catch an anticipated error (Added exception handling for the ForEach loop)
                11/12/2021 - Created PSCustomObject hash table (Modified object creation to use [PSCustomerObject])
    
    
    .EXAMPLE
    PS C:\>.\Test-CloudFlare -Computername DistinguishOpinion
    Example 1:  Test connectivity to CloudFlare DNS on that specific computer
    
    .EXAMPLE
    PS C:\>.\Test=CloudFlare -Computername DistinghuishOpinion -Output TXT
    Example 2:  Test connectivity to CloudFlare DNS and writes the output to a TXT file
    
    .EXAMPLE
    ps c:\>.\Test=CloudFlare -Computername DistinguishOpinion -Output CSV
    Example 3:  Test connectivity to CloudFlare DNS and writes the output to a CSV file. 
    #>
    [cmdletbinding()]
        param (
            [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
            [Alias('CN' , 'Name')]
            [string[]]$Computername,        
            [Parameter(Mandatory=$False)]
            [string]$Path = "$Env:USERPROFILE",
            [ValidateSet('Host','Text','CSV')]       
            [string]$Output = "Host"        
        )#Param
    
        ForEach ($Computer in $Computername) {
            Try {
                #Creates a new session to the remote computer(s) 
                $Params = @{
                    'Computername' = $Computer
                    'ErrorAction' = 'Stop'
                    
                }#Params
                $Session = New-PSSession @Params
    
                Write-Verbose "Connecting to $Computername..."
    
                #Remotely runs Test-NetConnection to 1.1.1.1 on target computer(s) as a background job
                Write-Verbose "Testing connection to One.One.One.One on $Computer ..."
                Enter-PSSession $Session
                $Datetime = Get-Date
                $TestCF = Test-NetConnection -Computername one.one.one.one -InformationLevel Detailed

                #Store needed properties in new object
                $OBJ = [PSCUstomObject]@{ 
                    'Computername' = $Computer
                    'Pingsuccess' = $TestCF.Pingsucceeded
                    'NameResolve' = $TestCF.NameResolutionSucceeded
                    'ResolvedAddresses' = $TestCF.ResolvedAddresses
                }#PSCustomerObject properties

                #Closes the session to the remote computer(s)
                Exit-PSSession
                Remove-PSSession $Session

            }   Catch { 
                
                Write-Host "Remote connection to $Computer failed" -Foregroundcolor Red 
                
            }#Try/Catch
        }#For-Each Ends
    
        #Displays results based on -Output parameter
        Write-Verbose "Receving test results ..."
        switch ($Output) {
            "Host" {
                $OBJ
            }#Host
            "CSV" {
                Write-Verbose "Generating results file ..."
                $OBJ | Export-CSV -path $Path\TestResults.csv
            }#CSV
            "Text" {
                #Creates a text file containing the name of the computer being tested, the date/time, and the job output
                Write-Verbose "Generating results file ..."
                $OBJ | Out-File $Path\TestResults.txt
                Add-Content $Path\RemTestNet.txt -value "Computer Tested: $Computer"
                Add-Content $Path\RemTestNet.txt -value "Date/Time Tested: $Datetime"
                Add-Content $Path\RemTestNet.txt -value (Get-Content $Path\TestResults.txt)
                Remove-Item $Path\TestResults.txt
                Write-Verbose "Opening Results ..."
                Notepad $Path\RemTestNet.txt
            }#Text
        }#Switch
        Write-Verbose "Finished running test"
    }#function