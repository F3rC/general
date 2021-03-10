<# Code for blog post "Parallel Execution with PSJobs and PowerCLI: Deploying New VMs"
https://fercorrales.com/parallel-execution-with-psjobs-and-powercli-deploying-new-vms #>

############################# User-defined variables. Can be replaced by Read-Host #############################
$NumVMs = 5 			#Amount of VMs to be deployed
$VMNamePrefix = 'MyVM'	#This will be the first part of the VM name, followed by a number from $Range
$Password = '123456'
$Username = 'domain\fcorrales'
$vCenterAddress = 'MyvCenter.domain.org'
$Template = 'MyTemplate'
$vHost = 'MyvHost'
$Datastore = 'MyDS'
$PortGroup = 'MyvDPG'
$Folder = 'MyFolder'
$WaitInterval = 30		#This will determine the amount of seconds to wait before checking the jobs status
$VerbosePreference = 'Continue'		#Set to SilentlyContinue to hide status messages
################################################################################################################

#Range defines VMs start and end numbers. I.e. amount of VMs.
$Range = 1..$NumVMs

foreach ($Num in $Range) {

    #The script block that is sent to the vCenter by each job
    $ScriptBlock = {
        
        #Supress most PowerCLI warnings and prompts
        Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings: $false -ParticipateInCeip: $false -Confirm: $false -Scope Session
        
        #Connect to vCenter
        Connect-VIServer -Server $Using:vCenterAddress -User $Using:Username -Password $Using:Password

        #Set VMs folder and port group
        $Location = Get-Folder -Name $Using:Folder
        $PortGroup = Get-VDPortgroup -Name $Using:PortGroup

        #Deploy the VMs from a template
        New-VM -Name "$Using:VMNamePrefix$Using:Num" -VMHost $Using:vHost -Datastore $Using:Datastore -Template $Using:Template -Portgroup $PortGroup -Location $Location -RunAsync

        #Disconnect from vCenter
        Disconnect-VIServer -Server $Using:vCenterAddress -Confirm: $false

    }

    #Start the jobs, one for each VM
    Start-Job -ScriptBlock $ScriptBlock -Name "Job$Num"

}

#Do / Until block to wait until all jobs are completed to show the output.
Do {
    $Jobs = Get-Job | Where-Object State -EQ 'Completed'

    If ($Jobs.Count -eq $Range.Length) {
        foreach ($Job in $Jobs) {
            Receive-Job -Id $Job.Id -Keep
        }
    }

    #Wait the amount of seconds defined in the value of $WaitInterval variable
    Start-Sleep -Seconds $WaitInterval

    Write-Verbose -Message "[$(Get-Date -Format 'MM/dd/yyyy - HH:mm')] Waiting 30 seconds for jobs to complete. $($Jobs.Count)/$($Range.Length) completed"
}

Until (
    $Jobs.Count -eq $Range.Length
)

#Return $VerbosePreference to its default value
If ($VerbosePreference -ne 'SilentlyContinue') {
   $VerbosePreference = 'SilentlyContinue'
}