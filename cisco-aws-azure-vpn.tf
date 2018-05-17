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

output "azure_csr_instance_ip" {
 value = "${module.aws_azure_cisco_vpn_connecter.azure_config_out}"
}
