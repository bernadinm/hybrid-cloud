data "azurerm_resource_group" "rg" {
  name = "${var.rg_name}"
}

data "azurerm_virtual_network" "current" {
  name                = "${var.vnet_name}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "public" {
  name                 = "cisco-csr-subnet"
  virtual_network_name = "${data.azurerm_virtual_network.current.name}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  address_prefix       = "${local.azure_csr_subnet_cidr_block}"
#  network_security_group_id = "${azurerm_network_security_group.cisco.id}"
}

# Public IP addresses
locals {
  azure_csr_subnet_cidr_block = "${join(".", list(element(split(".", data.azurerm_virtual_network.current.address_spaces[0]),0), element(split(".", data.azurerm_virtual_network.current.address_spaces[0]),1), var.subnet_suffix_cidrblock))}"
  azure_csr_private_ip = "${join(".", list(element(split(".", data.azurerm_virtual_network.current.address_spaces[0]),0), element(split(".", data.azurerm_virtual_network.current.address_spaces[0]),1), var.private_ip_address_suffix))}"
}

resource "azurerm_public_ip" "cisco" {
  name                         = "cisco-pip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

# Agent Security Groups for NICs
resource "azurerm_network_security_group" "cisco_security_group" {
  name                         = "cisco-csr-security-group"
  location = "${var.azure_region}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "cisco_sshRule" {
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
    network_security_group_name = "${azurerm_network_security_group.cisco_security_group.name}"
}


resource "azurerm_network_security_rule" "cisco_internalEverything" {
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
    network_security_group_name = "${azurerm_network_security_group.cisco_security_group.name}"
}

resource "azurerm_network_security_rule" "cisco_everythingElseOutBound" {
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
    network_security_group_name = "${azurerm_network_security_group.cisco_security_group.name}"
}
# End of Agent NIC Security Group

# Agent NICs with Security Group
resource "azurerm_network_interface" "cisco_nic" {
  name                      = "cisco-nic"
  location                  = "${var.azure_region}"
  resource_group_name       = "${data.azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.cisco_security_group.id}"

  ip_configuration {
   name                                    = "cisco_ipConfig"
   subnet_id                               = "${azurerm_subnet.public.id}"
   private_ip_address_allocation           = "dynamic"
   public_ip_address_id                    = "${azurerm_public_ip.cisco.id}"
  }
}

# Agent VM Coniguration
resource "azurerm_virtual_machine" "cisco" {
    name                             = "cisco-csr"
    location                         = "${var.azure_region}"
    resource_group_name              = "${data.azurerm_resource_group.rg.name}"
    network_interface_ids            = ["${azurerm_network_interface.cisco_nic.id}"]
    vm_size = "Standard_D2_v2"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    plan {
        name = "csr-azure-byol"
        product = "cisco-csr-1000v"
        publisher = "cisco"
    }
    vm_size = "Standard_D2_v2"
    storage_image_reference {
        publisher = "cisco"
        offer = "cisco-csr-1000v"
        sku = "csr-azure-byol"
        version = "16.40.120170206"
    }


  storage_os_disk {
    name              = "cisco_disk-os"
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
    cisco_hostname = "${azurerm_public_ip.cisco.ip_address}"
    cisco_password = "${var.cisco_password}"
    cisco_user    = "${var.cisco_user}"
   }
}

output "cisco" {
  value = ["${azurerm_public_ip.cisco.*.ip_address}"]
}

module "azure_csr_userdata" {
  source = "../cisco-config-generator"
  public_ip_local_site   = "${coalesce(var.public_ip_local_site, azurerm_public_ip.cisco.ip_address)}"
  private_ip_local_site  = "${local.azure_csr_private_ip}"
  public_ip_remote_site  = "${coalesce(var.public_ip_remote_site, aws_eip.csr.public_ip)}"
  private_ip_remote_site = "${coalesce(var.private_ip_remote_site, local.aws_csr_private_ip)}"
  tunnel_ip_local_site   = "${var.tunnel_ip_remote_site}"
  tunnel_ip_remote_site  = "${var.tunnel_ip_local_site}"
  local_hostname         = "${var.remote_hostname}"
}

resource "null_resource" "ssh_deploy" {
  triggers {
    cisco_ids = "${azurerm_virtual_machine.cisco.id}"
  }
  connection {
    host = "${var.docker_utility_node}"
    user = "${var.docker_utility_node_username}"
  }

  provisioner "file" {
    content     = "${data.template_file.ssh_template.rendered}"
    destination = "cisco-config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x cisco-config.sh",
      "sudo ./cisco-config.sh",
    ]
  }
}

output "azure_private_ip_address" {
  value = "${azurerm_network_interface.cisco_nic.private_ip_address}"
}

output "azure_ssh_user" {
  value = "${var.cisco_user}"
}

data "template_file" "azure-terraform-dcos-default-cidr" {
  template = "$${cloud == "aws" ? "10.0.0.0/16" : cloud == "gcp" ? "10.64.0.0/16" : "undefined"}"

  vars {
    cloud = "${var.local_terraform_dcos_destination_provider}"
  }
}
