# Used to manage remote Azure region
variable "azure_remote_region" {
  default = "UK South"
}

# Used to manage remote Azure region
variable "num_of_remote_azure_private_agents" {
  default = "1"
}

# Used to manage remote Azure region
variable "num_of_remote_azure_public_agents" {
  default = "1"
}

# Create a resource group
resource "azurerm_resource_group" "dcos_remote" {
  name     = "dcos-remote-${data.template_file.cluster-name.rendered}"
  location = "${var.azure_remote_region}"

  tags { 
   Name       = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
   expiration = "${var.expiration}"
  }
}

# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "vnet_remote" {
  name                = "vnet_remote-${data.template_file.cluster-name.rendered}"
  address_space       = ["10.33.0.0/16"]
  location            = "${var.azure_remote_region}"
  resource_group_name = "${azurerm_resource_group.dcos_remote.name}"

  tags { 
   Name       = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
   expiration = "${var.expiration}"
  }
}

resource "azurerm_subnet" "public_remote" {
  name                      = "public_remote"
  address_prefix            = "10.33.0.0/22"
  virtual_network_name      = "${azurerm_virtual_network.vnet_remote.name}"
  resource_group_name       = "${azurerm_resource_group.dcos_remote.name}"
  route_table_id            = "${azurerm_route_table.private_remote.id}"
}

resource "azurerm_subnet" "private_remote" {
  name                 = "private_remote"
  address_prefix       = "10.33.4.0/22"
  virtual_network_name = "${azurerm_virtual_network.vnet_remote.name}"
  resource_group_name  = "${azurerm_resource_group.dcos_remote.name}"
  route_table_id       = "${azurerm_route_table.private_remote.id}"
}

# Public Subnet Security Groups
resource "azurerm_network_security_group" "public_subnet_security_group_remote" {
    name = "${data.template_file.cluster-name.rendered}-master-security-group"
    location = "${var.azure_remote_region}"
    resource_group_name = "${azurerm_resource_group.dcos_remote.name}"

    tags { 
      Name       = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
      expiration = "${var.expiration}"
  }
}

# Public Subnet NSG Rule
resource "azurerm_network_security_rule" "master-sshRule_remote" {
    name                        = "sshRule"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.dcos_remote.name}"
    network_security_group_name = "${azurerm_network_security_group.public_subnet_security_group_remote.name}"
}

resource "azurerm_network_security_rule" "public-subnet-httpRule_remote" {
    name                        = "HTTP"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "80"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.dcos_remote.name}"
    network_security_group_name = "${azurerm_network_security_group.public_subnet_security_group_remote.name}"
}

# Public Subnet NSG Rule
resource "azurerm_network_security_rule" "public-subnet-httpsRule_remote" {
    name                        = "HTTPS"
    priority                    = 120
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "443"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.dcos_remote.name}"
    network_security_group_name = "${azurerm_network_security_group.public_subnet_security_group_remote.name}"
}

output "ssh_user_remote" {
 value = "${module.azure-tested-oses.user}"
}

resource "azurerm_route_table" "private_remote" {
# TODO(mbernadin): current data azurerm_subnet does not support associating
# existing resources with routing tables. Creating this one to make hybrid cloud
# work explicitly
    name = "dcos_remote_cisco_vpn_route_table"
    location = "${var.azure_remote_region}"
    resource_group_name = "${azurerm_resource_group.dcos_remote.name}"

    route {
        name = "RemoteCiscoRouter"
        address_prefix = "${aws_vpc.default.cidr_block}"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = "${module.aws_azure_cisco_vpn_connecter.private_azure_csr_private_ip}"
    }

    route {
        name = "RemoteCiscoRouter-Spoke"
        address_prefix = "${aws_vpc.bursted_region.cidr_block}"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = "${module.remote_aws_azure_cisco_vpn_connecter.private_azure_csr_private_ip}"
    }
}
