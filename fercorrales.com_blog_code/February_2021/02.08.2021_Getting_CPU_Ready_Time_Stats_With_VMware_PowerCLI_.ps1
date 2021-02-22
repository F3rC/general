<# Code for blog post "Getting CPU Ready Time Stats With VMware PowerCLI"
https://fercorrales.com/getting-cpu-ready-time-stats-with-vmware-powercli #>

##### Create a connection to a vCenter here (if not yet connected) #####

# User Variables #############################################################
$StartDate = [datetime]'02/02/2021'
$EndDate = [datetime]'02/07/2021'
$IntervalMins = 30
$Entity = Get-VM -Name MyVM
$OutputPath = 'C:\CPU_Ready_Time_Report2.csv'
##############################################################################

#Convert interval from minutes to seconds, a requirement for the formula
$IntervalSecs = $IntervalMins * 60

#Get cpu.ready.summation stats for $Entity and save them in a variable
$CPUSumStats = Get-Stat -Stat cpu.ready.summation -Entity $Entity -Start $StartDate -Finish $EndDate -IntervalMins $IntervalMins

<#Transform each cpu.ready.summation value into CPU Ready Time percentage,
creates an object with the Entity, CPUReadyTime and TimeStamp properties#>
foreach ($Stat in $CPUSumStats) {
    
    #Formula
    $CPUReady = ($Stat.Value / ($IntervalSecs * 1000)) * 100
    
    #Add properties from original object to the new object
    $TimeStamp = $Stat.Timestamp
    $Entity = $Stat.Entity

    #Create object
    $Obj = [pscustomobject]@{
        'Entity' = $Entity
        'CPUReadyTime' = '{0:n2}' -f $CPUReady
        'TimeStamp' = $TimeStamp
    }

    #Export object to csv
    $Obj | Export-Csv -Path $OutputPath -Append -NoTypeInformation

}

##### Disconnect from vCenter if connection is no longer needed #####
