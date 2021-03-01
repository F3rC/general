#region credentials / authentication
$DstNSXTServer = 'https://mynsxtsrc.org'
$SrcNSXTServer = 'https://mynsxtdst.org'

$Username = 'admin'
$SrcPass = 'MySrcPass' | ConvertTo-SecureString -AsPlainText -Force
$DstPass = 'MyDstPass' | ConvertTo-SecureString -AsPlainText -Force

$DstCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$DstPass
$SrcCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$SrcPass
#endregion credentials / authentication


#region get new services information
#Get services in src site
$SrcResults = Invoke-RestMethod -Authentication Basic -SkipCertificateCheck -Method Get -Uri "$SrcNSXTServer/policy/api/v1/infra/services" -Credential $SrcCred |
Select-Object -ExpandProperty results

#Get services in dst site
$DstResults = Invoke-RestMethod -Authentication Basic -SkipCertificateCheck -Method Get -Uri "$DstNSXTServer/policy/api/v1/infra/services" -Credential $DstCred |
Select-Object -ExpandProperty results

#Compare dst with src
$ServiceDiff = Compare-Object -ReferenceObject $SrcResults -DifferenceObject $DstResults -Property id | Select-Object -ExpandProperty id

#Extract from src services ($SrcResults) the ones not present in dst
$ServicesToAdd = $SrcResults | Where-Object id -in $ServiceDiff

#Set counter to 0. It will be used to show progress
$Counter = 0
#endregion get new services information


#Main foreach structure to iterate through services from previous step
foreach ($Service in $ServicesToAdd) {
    
    #Add the first 4 lines of the request body to the $Body variable , these are service properties
    $Body = "
    {
        ""description"": ""$($Service.description)"",
        ""display_name"": ""$($Service.display_name)"",
        ""_revision"": 0,
        ""service_entries"": ["
    
    #Nested loop to iterate through each service entry
    foreach ($Service_entry in $Service.service_entries) {
        <#If the service entry type is 'NestedServiceServiceEntry' add the lines in $Service_entry_text
          to the request body ($Body variable). These are service entry properties#>
        If ($Service_entry.resource_type -eq 'NestedServiceServiceEntry') {
            $Service_entry_text = "
            {
                ""resource_type"": ""NestedServiceServiceEntry"",
                ""display_name"": ""$($Service_entry.display_name)"",
                ""nested_service_path"": ""$($Service_entry.nested_service_path)""
            },"
            $Body = $Body.Insert($Body.Length,"`n$Service_entry_text")
        }

        <#If the service entry type is 'L4PortSetServiceEntry' check if both source and destination ports
          are specified and, if true, add the lines in $Service_entry_text to the request body ($Body variable).
          These are service entry properties#>
        ElseIf ($Service_entry.resource_type -eq 'L4PortSetServiceEntry') {
            If ($null -ne $Service_entry.source_ports -and $null -ne $Service_entry.destination_ports) {
                $Service_entry_text = "
                {
                    ""resource_type"": ""L4PortSetServiceEntry"",
                    ""display_name"": ""$($Service_entry.display_name)"",
                    ""destination_ports"": [
                        ""$($Service_entry | Select-Object -ExpandProperty destination_ports)""
                    ],
                    ""source_ports"": [
                        ""$($Service_entry | Select-Object -ExpandProperty source_ports)""
                    ],
                    ""l4_protocol"": ""$($Service_entry.l4_protocol)""
                },"
            }

            <#If the service entry type is 'L4PortSetServiceEntry' check if only source ports are specified and,
              if true, add the lines in $Service_entry_text to the request body ($Body variable). These are service
              entry properties#>
            If ($Service_entry.source_ports) {
                $Service_entry_text = "
                {
                    ""resource_type"": ""L4PortSetServiceEntry"",
                    ""display_name"": ""$($Service_entry.display_name)"",
                    ""source_ports"": [
                        ""$($Service_entry | Select-Object -ExpandProperty source_ports)""
                    ],
                    ""l4_protocol"": ""$($Service_entry.l4_protocol)""
                },"
            }

            <#If the service entry type is 'L4PortSetServiceEntry' check if only destination ports are specified
              and, if true, add the lines in $Service_entry_text to the request body ($Body variable). These are
              service entry properties#>
            If ($Service_entry.destination_ports) {
                $Service_entry_text = "
                {
                    ""resource_type"": ""L4PortSetServiceEntry"",
                    ""display_name"": ""$($Service_entry.display_name)"",
                    ""destination_ports"": [
                        ""$($Service_entry | Select-Object -ExpandProperty destination_ports)""
                    ],
                    ""l4_protocol"": ""$($Service_entry.l4_protocol)""
                },"
            }

            #Insert the text stored in variable $Service_entry_text at the end of the $Body variable
            $Body = $Body.Insert($Body.Length,"`n$Service_entry_text")
        }
    }


    #region Add closing characters to body and remove the comma from the last service entry in the array
    $ClosingText = '
        ]
    }'

    $Body = $Body.Insert($Body.Length,"`n$ClosingText")
    $Body = $Body.Remove($Body.LastIndexOf(','),1)
    #endregion Add closing characters to body and remove the comma from the last service entry in the array


    #Send the REST request to NSX-T Manager
    Invoke-RestMethod -Authentication Basic -SkipCertificateCheck -Method Patch -Uri "$DstNSXTServer/policy/api/v1/infra/services/$($Service.id)" -Credential $DstCred -Body $Body -ContentType 'application/JSON'
    
    #Add 1 to counter
    $Counter ++

    <#Message to show progress, Write-Host used for this example. Write-Progress or Write-Verbose may be more 
      appropriate but I personally like the ability to add color to the text.#>
    Write-Host "Processed $Counter services of $($ServicesToAdd.Count)" -ForegroundColor Yellow
}