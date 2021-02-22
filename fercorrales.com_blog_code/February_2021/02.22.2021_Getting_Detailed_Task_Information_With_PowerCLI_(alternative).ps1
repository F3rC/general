Function Get-ViTask {

<#
.SYNOPSIS
Retrieves detailed task information from a vCenter or ESXi server.

.DESCRIPTION
This function retrieves detailed task information from a vCenter or ESXi
server. By default the 'Get-Task' PowerCLI cmdlet does not display basic
information like username and entity / target.

.EXAMPLE
Get-VTask | Format-Table

Retrieves detailed information for all tasks, then formats the output as
table. The default output is formatted as list.

.EXAMPLE
Get-VTask -Username 'MyDomain\John.Doe' -Status Running

Retrieves detailed information for all running tasks started by user
'MyDomain\Jonh.Doe'.

.EXAMPLE
Get-VTask -Id Task-task-1511207

Retrieves detailed information for task with Id 'Task-task-1511207'.
#>
    
    #region Parameter Block
    
    <#
    PowerCLI original Get-Task cmdlet, has two parameter sets, one uses
    'Id' and another one uses 'Status'. Therefore, this function needs
    the same parameter sets. Parameters 'Entity' and 'Username' are added
    to both parameter sets as they are not mutually exclusive and they do
    not conflict neither with Id nor with Status.
    #>

    [CmdletBinding (DefaultParameterSetName = 'Status')]
    param (
        
        [Parameter (ParameterSetName = 'Status')]
        [ValidateSet ('Cancelled','Error','Queued','Running','Success','Unknown')]
        #Same options from Get-Task
            [string]$Status,
        
        [Parameter (ParameterSetName = 'Id')]
            [string[]]$Id,
        
        [Parameter (ParameterSetName = 'Status')]
        [Parameter (ParameterSetName = 'Id')]
            [string]$Entity,
            <#Default Entity value set to * to ensure results include
              all entities when omitted in the command.#>
        
        [Parameter (ParameterSetName = 'Status')]
        [Parameter (ParameterSetName = 'Id')]
            [string]$Username
            <#Default Username value set to * to ensure results include
              all entities when omitted in the command.#>
    )

    #endregion Parameter Block

    BEGIN {

    <#
    The BEGIN block determines which task objects will be processed by
    filtering them based on Id, Username, Status, Entity or a valid
    combination of these parameters. These filtered objects will be the
    source of data for the new custom objects that will be generated in
    the PROCESS block.
    #>
        switch ($PSBoundParameters) {
            {$_.ContainsKey('Status')} {$Tasks = Get-Task -Status $Status}
            {$_.ContainsKey('Id')} {$Tasks = Get-Task -Id $Id}
            Default {$Tasks = Get-Task}
    } <#This switch statement determines whether Status or Id were
        specified in the command, only one is allowed by parameter sets.
        If not, all tasks are retrieved. Otherwise, Task objects are
        returned based on the value of either parameter, and stored in
        the $Tasks variable.#>

    } #BEGIN

    PROCESS {
        
        If ($PSBoundParameters.ContainsKey('Username') -and $PSBoundParameters.ContainsKey('Entity')) {
            $Tasks | Where-Object {$_.ExtensionData.Info.Reason.UserName -eq $Username -and $_.ExtensionData.Info.EntityName -eq $Entity} |
            ForEach-Object -Process {
                <# Custom object is created with new parameters that
                   extend the information provided by the original Get-
                   Task cmdlet#>
                    $TaskObject = [PSCustomObject] @{
                        'Entity' = $_.ExtensionData.Info.EntityName
                        'Description' = $_.Description
                        'Status' = $_.State
                        'Progress' = $_.PercentComplete
                        'Username' = $_.ExtensionData.Info.Reason.UserName
                        'Message' = $_.ExtensionData.Info.Description.Message
                        'Id' = $_.Id
                        'StartTime' = $_.ExtensionData.Info.StartTime
                        'CompleteTime' = $_.ExtensionData.Info.CompleteTime
                        'IsCancellable' = $_.ExtensionData.Info.Cancelable
                    }

                #region set new object type
                <#The following lines set the object's new type to
                  'System.Custom.VTask'#>
                $TaskObject.PSObject.TypeNames.Clear() 
                $TaskObject.PSObject.TypeNames.Add('System.Custom.VTask')
                #endregion set new object type

                $TaskObject | Write-Output
                #Displays the new objects onscreen
            }
        } <#If values for Username and Entity were specified objects are
            filtered based on the values entered.#>
                
        ElseIf ($PSBoundParameters.ContainsKey('Username')) {
            $Tasks | Where-Object {$_.ExtensionData.Info.Reason.UserName -eq $Username} |
            ForEach-Object -Process {
                <# Custom object is created with new parameters that
                   extend the information provided by the original Get-
                   Task cmdlet#>
                    $TaskObject = [PSCustomObject] @{
                        'Entity' = $_.ExtensionData.Info.EntityName
                        'Description' = $_.Description
                        'Status' = $_.State
                        'Progress' = $_.PercentComplete
                        'Username' = $_.ExtensionData.Info.Reason.UserName
                        'Message' = $_.ExtensionData.Info.Description.Message
                        'Id' = $_.Id
                        'StartTime' = $_.ExtensionData.Info.StartTime
                        'CompleteTime' = $_.ExtensionData.Info.CompleteTime
                        'IsCancellable' = $_.ExtensionData.Info.Cancelable
                    }

                #region set new object type
                <#The following lines set the object's new type to
                  'System.Custom.VTask'#>
                $TaskObject.PSObject.TypeNames.Clear() 
                $TaskObject.PSObject.TypeNames.Add('System.Custom.VTask')
                #endregion set new object type

                $TaskObject | Write-Output
                #Displays the new objects onscreen
            }
        } <#If a value for Username was specified objects are filtered
           based on the value entered.#>
            
        ElseIf ($PSBoundParameters.ContainsKey('Entity')) {
            $Tasks | Where-Object {$_.ExtensionData.Info.EntityName -eq $Entity} |
            ForEach-Object -Process {
                <#Custom object is created with new parameters that
                  extend the information provided by the original Get-
                  Task cmdlet#>
                    $TaskObject = [PSCustomObject] @{
                        'Entity' = $_.ExtensionData.Info.EntityName
                        'Description' = $_.Description
                        'Status' = $_.State
                        'Progress' = $_.PercentComplete
                        'Username' = $_.ExtensionData.Info.Reason.UserName
                        'Message' = $_.ExtensionData.Info.Description.Message
                        'Id' = $_.Id
                        'StartTime' = $_.ExtensionData.Info.StartTime
                        'CompleteTime' = $_.ExtensionData.Info.CompleteTime
                        'IsCancellable' = $_.ExtensionData.Info.Cancelable
                    }

                #region set new object type
                <#The following lines set the object's new type to
                  'System.Custom.VTask'#>
                $TaskObject.PSObject.TypeNames.Clear() 
                $TaskObject.PSObject.TypeNames.Add('System.Custom.VTask')
                #endregion set new object type

                $TaskObject | Write-Output
                #Displays the new objects onscreen
            }
        } <#If a value for Entity was specified objects are filtered
            based on the value entered.#>


        Else {
            $Tasks | ForEach-Object -Process {
                <#Custom object is created with new parameters that
                  extend the information provided by the original Get-
                  Task cmdlet#>
                    $TaskObject = [PSCustomObject] @{
                        'Entity' = $_.ExtensionData.Info.EntityName
                        'Description' = $_.Description
                        'Status' = $_.State
                        'Progress' = $_.PercentComplete
                        'Username' = $_.ExtensionData.Info.Reason.UserName
                        'Message' = $_.ExtensionData.Info.Description.Message
                        'Id' = $_.Id
                        'StartTime' = $_.ExtensionData.Info.StartTime
                        'CompleteTime' = $_.ExtensionData.Info.CompleteTime
                        'IsCancellable' = $_.ExtensionData.Info.Cancelable
                    }

                #region set new object type
                <#The following lines set the object's new type to
                  'System.Custom.VTask'#>
                $TaskObject.PSObject.TypeNames.Clear() 
                $TaskObject.PSObject.TypeNames.Add('System.Custom.VTask')
                #endregion set new object type

                $TaskObject | Write-Output
                #Displays the new objects onscreen
            }
        } <#If no values were specified objects are not filtered and all
            tasks are returned.#>
 
    } #PROCESS

    END {}
}