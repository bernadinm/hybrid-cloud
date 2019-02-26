# enable global peering between the two virtual network 
resource "azurerm_virtual_network_peering" "peering_a" {
  name                         = "peering-connection_a"
  resource_group_name          = "${azurerm_resource_group.dcos.name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet_remote.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit        = false
}

# enable global peering between the two virtual network 
resource "azurerm_virtual_network_peering" "peering_b" {
  name                         = "peering-connection_b"
  resource_group_name          = "${azurerm_resource_group.dcos_remote.name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet_remote.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit        = false
}
