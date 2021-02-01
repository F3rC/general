<# Code for blog post "Function: Search Datastores for Files with PowerCLI PSProvider (vimdatastore)"
https://fercorrales.com/function-search-datastores-for-files-with-powercli-psprovider-vimdatastore #>

Function Search-DatastoreItem {

<#
.SYNOPSIS
This function allows to search files in datastores.

.DESCRIPTION
This scripts allows to search files in datastores. It searches for files that matches the provided search expression/string.
The datastore(s) can be specified, all datastores are searched by default. The output is a list of matching files or folders
their respective type and the path in the datastore.

.PARAMETER Expression
Required/mandatory. It consists of a search expression that accepts partial names and wildcard characters.

.PARAMETER Datastore
Optional. All datastores are searched if omitted. It can be specified by using its alias DC

.EXAMPLE
PS C:\> Search_DatastoreItem -DS 'MyDS04','MyDS10' -Expression *SQL*

Searches for all files containing the string 'office' in their names. It uses the 'DC' alias to specify 'MyDS04' and 
'MyDS10' as value for the Datastore parameter. Only those two datastores are searched.

.EXAMPLE
PS C:\> Search_DatastoreItem *office*

Searches all datastores for all files containing the string 'office' in their names. Note that since no value was entered
for the 'Datastore' parameter, by default all datastores are searched. In addition, since the parameters are positional,
typing the parameter name is optional as long as the values match the parameters in position, 1 for 'Expression' and 2 for
'Datastore'

.EXAMPLE
PS C:\> Search_DatastoreItem -Expression '*office 2013*' -Datastore 'MyDS10' -Verbose

Searches datastore 'MyDS10' for the string 'office 2013'. Note the single quotes in the search expression, if there is
a space in the search string, it must be wrapped in single or double quotes. The Verbose parameter is specified in order to
get runtime messages with updates about the execution status.

.INPUTS
A search expression of type string and datastore names of type string.

.OUTPUTS
List of files and folders displaying filename, datastore path and item type.

.NOTES

 1. Use the Verbose parameter to see information in the console about the execution progress. Also note there
    is a progress bar that displays the current execution status.
 2. An active PowerCLI connection / session to a SINGLE vCenter is required prior to running this function.
 3. The search is recursive, not only the root of the datastore is scanned but all child folders as well.
 4. If expressions include spaces they must be enclosed in single (or double) quotes.
 5. Expressions should only include regular wildcard characters such as '*', '?', '[0-9]', [a-z].
 6. Expressions can include the exact name of a file if it is known, no wildcards are required in this case.
    To search using part of a file name, wildcards are always required.
 7. Searches are not case sensitive.
 8. Use the Datastore parameter or its alias, DS in order to specify one or more Datastores to search. Type
    their names separated by commas.
#>


##### Create a connection to a vCenter here (if not yet connected) #####

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Expression,
        
        [Parameter(ValueFromPipeline,
                   Position=1)]
        [Alias('DS')]
        [string[]]$Datastore = '*'
    )

    BEGIN {

        #Variable required to count loop executions. Used to calculate progress in 'Write-Progress' below.
        $Counter = 0

    }
    
    PROCESS {
    
        #Get collection of datastores to search.
        $DSNames = Get-Datastore -Name $Datastore | Where-Object {$_.Name -notlike 'ma-ds-*'} | Sort-Object Name | Select-Object -ExpandProperty Name

        <#Begin search: foreach loop - datastores are scanned to find matches to the expression entered before.
        'Write-Progress' cmdlet shows percentage complete based on the total count of '$DSNames' and total datastores scanned ($Counter).#>
        foreach ($DS in $DSNames) {
            
            $Percent = '{0:n2}' -f (100/$DSNames.Count*$Counter)
            Write-Progress -Activity 'Searching datastores' -PercentComplete $Percent -CurrentOperation "Searching $DS" -Status "$Percent% Complete - $Counter of $($DSNames.Count) datastore(s) completed"

            Set-Location "vmstore:\$(Get-Datacenter)"
            
            Write-Verbose "Searching $DS"

            Set-Location $DS

            Get-ChildItem -Filter $Expression -Recurse | Select-Object Name,FolderPath,ItemType | Format-Table -AutoSize

            Write-Verbose "Done with $DS"

            Set-Location ..
            $Counter ++
        } #foreach

        #Change drive to HOMEDRIVE environment variable value to leave Datastore provider and change back to the main local drive.
        .$env:HOMEDRIVE

    } #PROCESS

    END {}

} #Function