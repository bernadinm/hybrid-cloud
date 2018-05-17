# Public IP addresses
resource "azurerm_public_ip" "testing_public_ip" {
  name                         = "oktesting"
  location                     = "${var.azure_region}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  domain_name_label = "oktesting-123"
}

# Agent Security Groups for NICs
resource "azurerm_network_security_group" "testing_security_group" {
  name                         = "oktesting"
    location = "${var.azure_region}"
    resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "testing-sshRule" {
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
    network_security_group_name = "${azurerm_network_security_group.testing_security_group.name}"
}


resource "azurerm_network_security_rule" "testing-internalEverything" {
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
    network_security_group_name = "${azurerm_network_security_group.testing_security_group.name}"
}

resource "azurerm_network_security_rule" "testing-everythingElseOutBound" {
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
    network_security_group_name = "${azurerm_network_security_group.testing_security_group.name}"
}
# End of Agent NIC Security Group

# Agent NICs with Security Group
resource "azurerm_network_interface" "testing_nic" {
  name                      = "testing"
  location                  = "${var.azure_region}"
  resource_group_name       = "${data.azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.testing_security_group.id}"

  ip_configuration {
   name                                    = "testing_ipConfig"
   subnet_id                               = "${azurerm_subnet.public.id}"
   private_ip_address_allocation           = "dynamic"
   public_ip_address_id                    = "${azurerm_public_ip.testing_public_ip.id}"
  }
}

# Agent VM Coniguration
resource "azurerm_virtual_machine" "testing" {
    name                             = "testing-cisco"
    location                         = "${var.azure_region}"
    resource_group_name              = "${data.azurerm_resource_group.rg.name}"
    network_interface_ids            = ["${azurerm_network_interface.testing_nic.id}"]
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

  storage_os_disk {
    name              = "testing-disk-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

    delete_os_disk_on_termination = true
    os_profile {
        computer_name = "${var.remote_hostname}"
        admin_username = "${var.cisco_user}"
        admin_password = "${var.cisco_password}"
        #custom_data = "enable-scp-server true"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

data "template_file" "ssh_template" {
   template = "${file("${path.module}/ssh-deploy-script.tpl")}"

   vars {
    cisco_commands = "${module.azure_csr_userdata.ssh_emulator}"
    cisco_hostname = "${azurerm_public_ip.testing_public_ip.ip_address}"
    cisco_password = "${var.cisco_password}"
    cisco_user    = "${var.cisco_user}"
   }
}

resource "null_resource" "local-exec" {
#  # Bootstrap script can run on any instance of the cluster
#  # So we just choose the first in this case
#  connection {
#    host = "${azurerm_public_ip.testing_public_ip.ip_address}"
#    user = "${var.cisco_user}"
#    agent = "false"
#    password = "${var.cisco_password}"
#  }
#
#  # Wait for bootstrapnode to be ready
  provisioner "local-exec" {
      command = "${data.template_file.ssh_template.rendered}"
   }
}

output "testing" {
  value = ["${azurerm_public_ip.testing_public_ip.*.fqdn}"]
}
