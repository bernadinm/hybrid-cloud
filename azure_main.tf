# Provide tested AMI and user from listed region startup commands
  module "azure-tested-oses" {
      source   = "./modules/dcos-tested-azure-oses"
      provider = "azure"
      os       = "${var.os}"
      region   = "${var.azure_region}"
}

# Public Subnet Security Groups
resource "azurerm_network_security_group" "public_subnet_security_group" {
    name = "${data.template_file.cluster-name.rendered}-master-security-group"
    location                 = "UK South"
    resource_group_name      = "hybrid-demo"
}

# Public Subnet NSG Rule
resource "azurerm_network_security_rule" "public-subnet-httpRule" {
    name                        = "HTTP"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "80"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "hybrid-demo"
    network_security_group_name = "${azurerm_network_security_group.public_subnet_security_group.name}"
}

# Public Subnet NSG Rule
resource "azurerm_network_security_rule" "public-subnet-httpsRule" {
    name                        = "HTTPS"
    priority                    = 120
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "443"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "hybrid-demo"
    network_security_group_name = "${azurerm_network_security_group.public_subnet_security_group.name}"
}
