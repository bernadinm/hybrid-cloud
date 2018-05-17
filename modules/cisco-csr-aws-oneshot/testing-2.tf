# Public IP addresses
resource "azurerm_public_ip" "testing2_public_ip" {
  name                         = "oktesting2"
  location                     = "${var.azure_region}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "oktesting2-123"
}

# Agent Security Groups for NICs
resource "azurerm_network_security_group" "testing2_security_group" {
  name                         = "oktesting2"
    location = "${var.azure_region}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "testing2-sshRule" {
    name                        = "sshRule"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${data.azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.testing2_security_group.name}"
}


resource "azurerm_network_security_rule" "testing2-internalEverything" {
    name                        = "allOtherInternalTraffric"
    priority                    = 160
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${data.azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.testing2_security_group.name}"
}

resource "azurerm_network_security_rule" "testing2-everythingElseOutBound" {
    name                        = "allOtherTrafficOutboundRule"
    priority                    = 170
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${data.azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.testing2_security_group.name}"
}
# End of Agent NIC Security Group

# Agent NICs with Security Group
resource "azurerm_network_interface" "testing2_nic" {
  name                      = "testing2"
  location                  = "${var.azure_region}"
  resource_group_name       = "${data.azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.testing2_security_group.id}"

  ip_configuration {
   name                                    = "testing2_ipConfig"
   subnet_id                               = "${azurerm_subnet.public.id}"
   private_ip_address_allocation           = "dynamic"
   public_ip_address_id                    = "${azurerm_public_ip.testing2_public_ip.id}"
  }
}

# Agent VM Coniguration
resource "azurerm_virtual_machine" "testing2" {
    name                             = "testing2-cisco"
    location                         = "${var.azure_region}"
    resource_group_name              = "${data.azurerm_resource_group.rg.name}"
    network_interface_ids            = ["${azurerm_network_interface.testing2_nic.id}"]
    vm_size = "Standard_D2_v2"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    plan {
        name = "16_6"
        product = "cisco-csr-1000v"
        publisher = "cisco"
    }
    vm_size = "Standard_D2_v2"
    storage_image_reference {
        publisher = "cisco"
        offer = "cisco-csr-1000v"
        sku = "16_6"
        version = "latest"
    }

#    plan {
#        name = "csr-azure-byol"
#        product = "cisco-csr-1000v"
#        publisher = "cisco"
#    }
#    vm_size = "Standard_D2_v2"
#    storage_image_reference {
#        publisher = "cisco"
#        offer = "cisco-csr-1000v"
#        sku = "csr-azure-byol"
#        version = "latest"
#    }
#
  storage_os_disk {
    name              = "testing2-disk-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

    delete_os_disk_on_termination = true
    os_profile {
        computer_name = "${var.remote_hostname}"
        admin_username = "${var.cisco_user}"
        admin_password = "${var.cisco_password}"
        #custom_data = "${module.azure_csr_userdata.userdata}"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

output "testing2" {
  value = ["${azurerm_public_ip.testing2_public_ip.*.fqdn}"]
}
