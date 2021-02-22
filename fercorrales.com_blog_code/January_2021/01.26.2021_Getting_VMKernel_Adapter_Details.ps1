<# Code for blog post "Getting VMKernel Adapter Details in vCenter with PowerCLI"
https://fercorrales.com/getting-vmkernel-port-vmk-details-in-vcenter-with-powercli #>

##### Create a connection to a vCenter here (if not yet connected) #####

$vHosts = Get-VMHost | Sort-Object Name

#Begin first loop
foreach ($vHost in $vHosts) {
    $VMHost = $vHost.Name
    $vmks = $vHost | Get-VMHostNetwork | Select-Object -ExpandProperty VirtualNic | Sort-Object Name

    #Begin second / nested loop
    foreach ($vmk in $vmks) {
        $VmkObjct = [pscustomobject] @{'VMHost' = $vmk.VMHost
                                  'DeviceName' = $vmk.DeviceName
                                  'IP' = $vmk.IP
                                  'DhcpEnabled' = $vmk.DhcpEnabled
                                  'SubnetMask' = $vmk.SubnetMask
                                  'Mac' = $vmk.Mac
                                  'VMotionEnabled' = $vmk.VMotionEnabled
                                  'ManagementTrafficEnabled' = $vmk.ManagementTrafficEnabled
                                  'MTU' = $vmk.Mtu}
    
    $VmkObjct | Export-Csv -Path ~\Documents\vmk.csv -Append -NoTypeInformation
    
    Write-Output $VmkObjct

    }#End second / nested loop
    
}#End first loop

##### Disconnect from vCenter if connection is no longer needed #####