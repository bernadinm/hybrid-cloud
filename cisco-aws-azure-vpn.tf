module "cisco_aws" {
  source = "modules/cisco-csr-aws"
  vpc_id = "${aws_vpc.default.id}"
  subnet_id = "${aws_subnet.public.id}"
  aws_region = "${var.aws_region}"
  aws_profile = "${var.aws_profile}"
  ssh_key_name = "default"
  instance_type = "c4.large"
  destination_cidr = "${azurerm_virtual_network.vnet.address_space[0]}"
}

module "cisco_azure" {
  source = "modules/cisco-csr-azure"
  azure_region = "${var.azure_region}"
  cisco_user = "cisco"
  cisco_password = "!QAZ@WSX3edc"
  rg_name = "${azurerm_resource_group.dcos.name}"
  vnet_name = "${azurerm_virtual_network.vnet.name}"
  destination_cidr = "${aws_vpc.default.cidr_block}"
}
    
module "cisco_site_configuration" {
  source = "modules/cisco-config-generator"
  public_ip_site_one  = "${module.cisco_aws.public_ip_address}"
  private_ip_site_one = "${module.cisco_aws.private_ip_address}"
  username_site_one   = "${module.cisco_aws.ssh_user}"
  public_ip_site_two  = "${module.cisco_azure.public_ip_address}"
  private_ip_site_two = "${module.cisco_azure.private_ip_address}"
  username_site_two   = "${module.cisco_azure.ssh_user}"
  password_site_two   = "${module.cisco_azure.password}"
}

resource "null_resource" "cisco_site_one_configuration" {
 connection {
    host = "${module.cisco_aws.public_ip_address}"
    user = "${module.cisco_aws.ssh_user}"
    agent = "false"
  }

  provisioner "remote-exec" {
    inline = "${module.cisco_site_configuration.site_one_config}"
  }
}

#resource "null_resource" "cisco_site_two_configuration" {
# connection {
#    host = "${module.cisco_aws.public_ip_address}"
#    user = "${module.cisco_aws.ssh_user}"
#    password = "!QAZ@WSX3edc"
#    agent = "false"
#  }
#
#  provisioner "remote-exec" {
#    inline = "${module.cisco_site_configuration.site_two_config}"
#  }
#}
