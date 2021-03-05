###################################################
#  Azure List User-defined Routes
#    - Loops through each Subscription > VNet > Subnet and output the User-defined Routes
#
#  Nathaniel Casperson, nathaniel.casperson@gmail.com
####################################################

### Loop through each subscription
$Subscriptions = Get-AzSubscription
foreach ($Subscription in $Subscriptions) {

    Write-Output "============================================================================"
    Write-Output "   CHECKING Subscription $($Subscription.Name)"
    Write-Output "============================================================================"
    Set-AzContext -Subscription $Subscription | Out-Null

    ### Loop through Virtual Network
    $VNets = Get-AzVirtualNetwork
    if ($VNets.count -eq 0) {
        "      No Virtual Network exists for this subscription"
    }
    else {
        foreach ($VNet in $VNets) {
            Write-Output "  --------------------------------------"
            Write-Output "    Checking VNet: $($VNet.Name)"
            
            ### Loop through Subnets
            $Subnets = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $VNet
            foreach ($Subnet in $Subnets) {
                Write-Output "    -------------------"
                Write-Output "      Subnet: $($Subnet.Name) `($($Subnet.AddressPrefix)`)"
                
                ### Loop through Route tables
                if ($Subnet.RouteTable.Count -eq 0) {
                    Write-Output "        No User-define Routes"
                }
                Else {
                    $RouteTable = Get-AzRouteTable -Name $Subnet.RouteTable.Id.Split("/")[-1]
                    Write-Output "      ---------"
                    Write-Output "        RouteTable: $($Subnet.RouteTable.Id.Split("/")[-1])"
                    
                    ### Loop through Routes
                    foreach ($Route in $RouteTable.Routes) {
#                        if ( ($Route.NextHopType -ne "Internet") -and ($Route.NextHopType -ne "VnetLocal") ) {
                            Write-Output "          Route: $($Route.Name)`tAddressPrefix: $($Route.AddressPrefix)`tNextHopType: $($Route.NextHopType)`tNextHopIpAddress: $($Route.NextHopIpAddress)"
#                        }
                    }
                }
            }
            Write-Output "  --------------------------------------"
        }
    }
}
