<# Code for blog post "PowerShell: Practical Use of PipelineVariable Common Parameter"
https://fercorrales.com/powershell-practical-use-of-pipelinevariable-common-parameter #>

<#First command#> Get-ADUser -Filter {Department -eq 'Technical Support'} -Properties EmailAddress -PipelineVariable User |
<#Second command#>Get-ADPrincipalGroupMembership |
<#Third command#> ForEach-Object -Process {
    $ADObj = [PSCustomObject] @{'LastName' = $User.Surname
                                'FirstName' = $User.GivenName
                                'SamAccountName' = $User.SamAccountName
                                'ADUserSID' = $User.SID
                                'EmailAddress' = $User.EmailAddress
                                'GroupName' = $_.Name
                                'GroupCategory' = $_.GroupCategory
                                'ADGroupSID' = $_.SID}
 
    Export-Csv -InputObject $ADObj -Path ~\Documents\ADUser_Group_Details.csv -Append -NoTypeInformation
    
}