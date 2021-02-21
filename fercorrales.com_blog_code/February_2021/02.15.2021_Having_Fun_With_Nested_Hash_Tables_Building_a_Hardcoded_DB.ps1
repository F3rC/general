<# Code for blog post "Having Fun With Nested Hash Tables: Building a Hard-coded DB"
https://fercorrales.com/having-fun-with-nested-hash-tables-building-a-hard-coded-db/ #>


$OSVersion = @(
    'Enterprise'
    'Pro'
    'Home'
)

$RAM = @(
    8
    4
)

$CPU = @(
    'Intel i7'
    'Intel i5'
)


$DellDesktopModels =
@{
#######################################################################################

'Optiplex' = @{
                'Brand' = 'Dell'
                'Model' = 'Optiplex'
                'Specs' = @{
                                'RAM' = "$($RAM[1]) GB"
                                'CPU' = $CPU[1]
                                'USB Ports' = '3'
                                'CD/DVD Drive' = 'No'
                                'HDD' = '320 GB - SSD'
                                'OperatingSystem' = @{
                                                        'OSName' = 'Microsoft Windows 10'
                                                        'Version' = $OSVersion[1]
                                                        'Build' = '19041'
                                                     } #Operating System
                           } #Specs
              } #Optiplex


#######################################################################################
    
'Vostro' = @{
                'Brand' = 'Dell'
                'Model' = 'Vostro'
                'Specs' = @{
                                'RAM' = "$($RAM[0]) GB"
                                'CPU' = $CPU[0]
                                'USB Ports' = '4'
                                'CD/DVD Drive' = 'Yes'
                                'HDD' = '500 GB - SSD'
                                'OperatingSystem' = @{
                                                        'OSName' = 'Microsoft Windows 10'
                                                        'Version' = $OSVersion[0]
                                                        'Build' = '19042'
                                                     } #Operating System
                           } #Specs

            } #Vostro


#######################################################################################    

'Inspiron' = @{
                'Brand' = 'Dell'
                'Model' = 'Inspiron'
                'Specs' = @{
                                'RAM' = "$($RAM[1]) GB"
                                'CPU' = $CPU[1]
                                'USB Ports' = '3'
                                'CD/DVD Drive' = 'No'
                                'HDD' = '1 TB - SATA'
                                'OperatingSystem' = @{
                                                        'OSName' = 'Microsoft Windows 10'
                                                        'Version' = $OSVersion[1]
                                                        'Build' = '19041'
                                                     } #Operating System
                           } #Specs
              } #Inspiron


#######################################################################################

'XPS' = @{
            'Brand' = 'Dell'
            'Model' = 'XPS'
            'Specs' = @{
                            'RAM' = "$($RAM[1]) GB"
                            'CPU' = $CPU[1]
                            'USB Ports' = '6'
                            'CD/DVD Drive' = 'Yes'
                            'HDD' = '500 GB - SATA'
                            'OperatingSystem' = @{
                                                    'OSName' = 'Microsoft Windows 10'
                                                    'Version' = $OSVersion[2]
                                                    'Build' = '18363'
                                                 } #Operating System
                       } #Specs
         } #XPS

#######################################################################################

} # Main hash table