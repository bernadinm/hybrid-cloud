# Privdes a unique ID thoughout the livespan of the cluster
resource "random_id" "cluster" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    id = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
  }

  byte_length = 8
}

# Create a resource group
resource "azurerm_resource_group" "dcos" {
  name     = "dcos-main-${data.template_file.cluster-name.rendered}"
  location = "${var.azure_region}"

  tags { 
   Name       = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
   expiration = "${var.expiration}"
  }
}

# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${data.template_file.cluster-name.rendered}"
  address_space       = ["10.32.0.0/16"]
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.dcos.name}"

  tags { 
   Name       = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
   expiration = "${var.expiration}"
  }
}

resource "azurerm_subnet" "public" {
  name                      = "public"
  address_prefix            = "10.32.0.0/22"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  resource_group_name       = "${azurerm_resource_group.dcos.name}"
  route_table_id            = "${azurerm_route_table.private.id}"
}

resource "azurerm_subnet" "private" {
  name                 = "private"
  address_prefix       = "10.32.4.0/22"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.dcos.name}"
  route_table_id       = "${azurerm_route_table.private.id}"
}

# Public Subnet Security Groups
resource "azurerm_network_security_group" "public_subnet_security_group" {
    name = "${data.template_file.cluster-name.rendered}-master-security-group"
    location = "${var.azure_region}"
    resource_group_name = "${azurerm_resource_group.dcos.name}"

    tags { 
      Name       = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
      expiration = "${var.expiration}"
  }
}

# Public Subnet NSG Rule
resource "azurerm_network_security_rule" "master-sshRule" {
    name                        = "sshRule"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.dcos.name}"
    network_security_group_name = "${azurerm_network_security_group.public_subnet_security_group.name}"
}

resource "azurerm_network_security_rule" "public-subnet-httpRule" {
    name                        = "HTTP"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "80"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.dcos.name}"
    network_security_group_name = "${azurerm_network_security_group.public_subnet_security_group.name}"
}

# Public Subnet NSG Rule
resource "azurerm_network_security_rule" "public-subnet-httpsRule" {
    name                        = "HTTPS"
    priority                    = 120
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "443"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.dcos.name}"
    network_security_group_name = "${azurerm_network_security_group.public_subnet_security_group.name}"
}

output "ssh_user" {
 value = "${module.azure-tested-oses.user}"
}
