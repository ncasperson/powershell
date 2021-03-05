###################################################
#  Azure Swap IPs
#    - Removes all the secondary IPs on the source VM
#    - Add all secondary IPs from source VM to the destination VM
#      where the NIC name suffix matches (-ext, -int, or -mgmt)
#  Nathaniel Casperson, nathaniel.casperson@gmail.com
####################################################
$ResourceGroup     = "azure-resourcegroup"
$SourceVmName      = "server-01"
$DestinationVmName = "server-02"

######
$SourceVm = Get-AzVm -Name $sourceVmName -ResourceGroupName $ResourceGroup
$SourceVmNics = $sourceVm.NetworkProfile.NetworkInterfaces
$DestinationVm = Get-AzVm -Name $DestinationVmName -ResourceGroupName $ResourceGroup
$DestinationVmNics = $DestinationVm.NetworkProfile.NetworkInterfaces

Write-Output "Source VM: $SourceVmName"

### Loop through each NIC on the source VM
foreach ($SourceNic in $SourceVmNics) {
    $Interface = Get-AzNetworkInterface -ResourceId $SourceNic.Id
    $IpConfigurations = $Interface.IpConfigurations | Where-Object {$_.Primary -ne $true} # finding only Secondary IPs

    ### Loop through each IP on the source VM NIC
    foreach ($IpConfiguration in $IpConfigurations) {
        Write-Output "    Source IP: $($IpConfiguration.PrivateIpAddress)"
        Write-Output "     SUBNET IS $($IpConfiguration.Subnet)"
        
        ### Loop through each NIC on the destination VM
        foreach ($DestinationNic in $DestinationVmNics) {

            ### Match the NIC name suffix (-ext, -int, or -mgmt) with source and destination NICs 
            If ( ($DestinationNic.Id -split '-')[-1] -eq ($SourceNic.Id -split '-')[-1] ) {
                $nic = Get-AzNetworkInterface -ResourceId $SourceNic.Id
                Write-Output "        Removing IP:"
                Write-Output "          FROM: $($SourceNic.Id)"
                Write-Output "             `$nic = Get-AzNetworkInterface -ResourceId $($SourceNic.Id)"
                Write-Output "             Remove-AzNetworkInterfaceIpConfig -Name $($IpConfiguration.Name) -NetworkInterface `$nic"
                Write-Output "             Set-AzNetworkInterface -NetworkInterface `$nic"
                
                ### Remove the IP from the source VM NIC
                Remove-AzNetworkInterfaceIpConfig -Name $IpConfiguration.Name -NetworkInterface $nic
                Set-AzNetworkInterface -NetworkInterface $nic
                $nic = $null

                $nic = Get-AzNetworkInterface -ResourceId $DestinationNic.Id
                Write-Output "        Adding IP:"
                Write-Output "          TO:   $($DestinationNic.Id)"
                Write-Output "             `$nic = Get-AzNetworkInterface -ResourceId $($DestinationNic.Id)"
                Write-Output "             Add-AzNetworkInterfaceIpConfig -Name $($IpConfiguration.Name) -PrivateIpAddress $($IpConfiguration.PrivateIpAddress) -Subnet $($IpConfiguration.Subnet.Id) -NetworkInterface `$nic"
                Write-Output "             Set-AzNetworkInterface -NetworkInterface `$nic"
                
                ### Add the IP to the destination VM NIC
                Add-AzNetworkInterfaceIpConfig -Name $IpConfiguration.Name -PrivateIpAddress $IpConfiguration.PrivateIpAddress -Subnet $IpConfiguration.Subnet -NetworkInterface $nic
                Set-AzNetworkInterface -NetworkInterface $nic
                $nic = $null
            }
        }
    }
}
