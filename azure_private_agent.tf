variable "num_of_private_agents" {
  default = "1"
}

variable "azure_admin_username" {
  description = "Username of the OS. (Defaults can be found here modules/dcos-tested-azure-oses/azure_template_file.tf)"
  default = ""
}

variable "azure_agent_instance_type" {
  description = "Azure DC/OS Private Agent instance type"
  default = "Standard_DS11_v2"
}

variable "azure_region" {
  description = "Azure region to launch servers."
  default     = "UK South"
}

variable "ssh_pub_key" {
  description = "The Public SSH Key associated with your instances for login. Copy your own key from your machine when deploying to log into your instance."
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCJtEX2fuZ4EWXCL3M37Qbr0mj3saEdhOwnLGJk8hr5xFOa8DoTs5IofaHfeRoiOKwfg44PW4fpDIz/e7X/9tmKTuwOszuAE9QTWQijZesCanLSf5nwYCTMsNGlUfxhjpJhcgQIcZ6vcDbNeGIQTElgsBKXoIXDosP3qjdWuwEEIfaQJDo4Mv16P+SqzPJ1KIV16lfw2NW71y7JzNApPRWxlxkoTiydv1hs6Ye6b6MTLLeDIsyzPqNro5/LpQkT7hr37pG88xC22Cn2lA18hhusP0wP+6pZbnbveKLVFkSdVlZAKgsEZ0UyAXsKElWtTHN+SXuqXmldg8h7n6GF1/tmEz7n/2+SBH+nNBlQPM/VOxW7yDwCKWr87mFI009a6ge66U4q+lqrfKzNSIsoamuICYg8GtAGK3yuPQq+pwFluJRUEihZQDlJ7IvezAKThglyDgV31D9frCqJ4gMTfzSnZ2PW54vJjNyAHZQoCqp/Y0aIdjwpnHw6F+blPmgXzzsheMahME7iCMQP1F/ckgXfq1rtI0mT1QNZhUtfFf1qYguNT0EdCGy3G3oWnHiIqjcq/wfhCTpf22ph7h1Q+b1ygXXIGnQWfyY/vZTDdW2lbrX36X/fZA3M74SBmQFEMWrul4tX//YwGtpHSyN380fdRHyCPPo6+BSB7KHVwDevw== default@mesosphere.com"
}

# Private Agents
resource "azurerm_managed_disk" "agent_managed_disk" {
  count                = "${var.num_of_private_agents}"
  name                 = "hybrid-cloud-agent-${count.index + 1}"
  resource_group_name  = "hybrid-demo"
  location             = "UK South"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.instance_disk_size}"
}

# Public IP addresses
resource "azurerm_public_ip" "agent_public_ip" {
  count                        = "${var.num_of_private_agents}"
  name                         = "hybrid-cloud-agent-pub-ip-${count.index + 1}"
  resource_group_name  = "hybrid-demo"
  location             = "UK South"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "hybrid-cloud-agent-${count.index + 1}"
}

# Agent Security Groups for NICs
resource "azurerm_network_security_group" "agent_security_group" {
    name = "hybrid-cloud-agent-security-group"
    resource_group_name  = "hybrid-demo"
    location             = "UK South"
}

resource "azurerm_network_security_rule" "agent-sshRule" {
    name                        = "sshRule"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name  = "hybrid-demo"
    network_security_group_name = "${azurerm_network_security_group.agent_security_group.name}"
}


resource "azurerm_network_security_rule" "agent-internalEverything" {
    name                        = "allOtherInternalTraffric"
    priority                    = 160
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name  = "hybrid-demo"
    network_security_group_name = "${azurerm_network_security_group.agent_security_group.name}"
}

resource "azurerm_network_security_rule" "agent-everythingElseOutBound" {
    name                        = "allOtherTrafficOutboundRule"
    priority                    = 170
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name  = "hybrid-demo"
    network_security_group_name = "${azurerm_network_security_group.agent_security_group.name}"
}
# End of Agent NIC Security Group

# Agent NICs with Security Group
resource "azurerm_network_interface" "agent_nic" {
  name                      = "hybrid-cloud-private-agent-${count.index}-nic"
  resource_group_name  = "hybrid-demo"
  location             = "UK South"
  network_security_group_id = "${azurerm_network_security_group.agent_security_group.id}"
  count                     = "${var.num_of_private_agents}"

  ip_configuration {
   name                                    = "hybrid-cloud-${count.index}-ipConfig"
   subnet_id                               = "/subscriptions/6bfddfe6-078b-4a9d-86ff-52e86464efe0/resourceGroups/hybrid-demo/providers/Microsoft.Network/virtualNetworks/hybridvnet/subnets/hybrid-csr-private"
   private_ip_address_allocation           = "dynamic"
   public_ip_address_id                    = "${element(azurerm_public_ip.agent_public_ip.*.id, count.index)}"
  }
}

# Create an availability set
resource "azurerm_availability_set" "agent_av_set" {
  name                         = "hybrid-cloud-agent-avset"
  resource_group_name  = "hybrid-demo"
  location             = "UK South"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 1
  managed                      = true
}

# Agent VM Coniguration
resource "azurerm_virtual_machine" "agent" {
    name                             = "hybrid-cloud-agent-${count.index + 1}"
    resource_group_name  = "hybrid-demo"
    location             = "UK South"
    network_interface_ids            = ["${azurerm_network_interface.agent_nic.*.id[count.index]}"]
    availability_set_id              = "${azurerm_availability_set.agent_av_set.id}"
    vm_size                          = "${var.azure_agent_instance_type}"
    count                            = "${var.num_of_private_agents}"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${module.azure-tested-oses.azure_publisher}"
    offer     = "${module.azure-tested-oses.azure_offer}"
    sku       = "${module.azure-tested-oses.azure_sku}"
    version   = "${module.azure-tested-oses.azure_version}"
  }

  storage_os_disk {
    name              = "os-disk-agent-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.agent_managed_disk.*.name[count.index]}"
    managed_disk_id = "${azurerm_managed_disk.agent_managed_disk.*.id[count.index]}"
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = "${azurerm_managed_disk.agent_managed_disk.*.disk_size_gb[count.index]}"
  }

  os_profile {
    computer_name  = "agent-${count.index + 1}"
    admin_username = "${coalesce(var.azure_admin_username, module.azure-tested-oses.user)}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/${coalesce(var.azure_admin_username, module.azure-tested-oses.user)}/.ssh/authorized_keys"
        key_data = "${var.ssh_pub_key}"
    }
  }

  # OS init script
  provisioner "file" {
   content = "${module.azure-tested-oses.os-setup}"
   destination = "/tmp/os-setup.sh"

   connection {
    type = "ssh"
    user = "${coalesce(var.azure_admin_username, module.azure-tested-oses.user)}"
    host = "${element(azurerm_public_ip.agent_public_ip.*.fqdn, count.index)}"
    }
 }

 # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
    provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/os-setup.sh",
      "sudo bash /tmp/os-setup.sh",
    ]

   connection {
    type = "ssh"
    user = "${coalesce(var.azure_admin_username, module.azure-tested-oses.user)}"
    host = "${element(azurerm_public_ip.agent_public_ip.*.fqdn, count.index)}"
   }
 }
}

resource "null_resource" "agent" {
  # If state is set to none do not install DC/OS
  count = "${var.state == "none" ? 0 : var.num_of_private_agents}"
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${null_resource.bootstrap.id}"
    current_virtual_machine_id = "${azurerm_virtual_machine.agent.*.id[count.index]}"
  }
  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(azurerm_public_ip.agent_public_ip.*.fqdn, count.index)}"
    user = "${coalesce(var.azure_admin_username, module.azure-tested-oses.user)}"
  }

  count = "${var.num_of_private_agents}"

  # Generate and upload Agent script to node
  provisioner "file" {
    content     = "${module.dcos-mesos-agent.script}"
    destination = "run.sh"
  }

  # Wait for bootstrapnode to be ready
  provisioner "remote-exec" {
    inline = [
     "until $(curl --output /dev/null --silent --head --fail http://${aws_instance.bootstrap.private_ip}/dcos_install.sh); do printf 'waiting for bootstrap node to serve...'; sleep 20; done"
    ]
  }

  # Install Agent Script
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x run.sh",
      "sudo ./run.sh",
    ]
  }
}
