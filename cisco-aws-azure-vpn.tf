variable "cisco_user" { default = "cisco" }
variable "cisco_password" { default = "ch@ngem3" }

module "aws_azure_cisco_vpn_connecter" {
  source = "modules/cisco-csr-aws-oneshot"
  vpc_id = "${aws_vpc.default.id}"
  aws_region = "${var.aws_region}"
  aws_profile = "${var.aws_profile}"
  ssh_key_name = "default"
  aws_instance_type = "c4.large"
  azure_region = "${var.azure_region}"
  vnet_name    = "${azurerm_virtual_network.vnet.name}"
  rg_name      = "${azurerm_resource_group.dcos.name}"
  owner = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
  expiration = "${var.expiration}"
  aws_docker_utility_node = "${aws_instance.bootstrap.public_ip}"
  aws_docker_utility_node_username = "${module.aws-tested-oses.user}"
  azure_docker_utility_node = "${azurerm_public_ip.bootstrap_public_ip.fqdn}"
  azure_docker_utility_node_username = "${module.azure-tested-oses.user}"
  cisco_user = "${var.cisco_user}"
  cisco_password = "${var.cisco_password}"
}

output "aws_config_out" {
 value = "${module.aws_azure_cisco_vpn_connecter.aws_config_out}"
}

output "aws_public_ip_address" {
 value = "${module.aws_azure_cisco_vpn_connecter.aws_public_ip_address}"
}

output "azure_public_ip_address" {
 value = "${module.aws_azure_cisco_vpn_connecter.azure_public_ip_address}"
}

output "azure_config_out" {
 value = "${module.aws_azure_cisco_vpn_connecter.azure_config_out}"
}

output "tmp" {
 value = "${module.aws_azure_cisco_vpn_connecter.tmp}"
}
output "snd" {
 value = "${module.aws_azure_cisco_vpn_connecter.snd}"
}
