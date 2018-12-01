module "remote_aws_azure_cisco_vpn_connecter" {
  source = "modules/cisco-csr-aws-oneshot"
  vpc_id = "${aws_vpc.bursted_region.id}"
  aws_region = "${var.aws_remote_region}"
  aws_profile = "${var.aws_profile}"
  ssh_key_name = "${var.ssh_key_name}"
  aws_instance_type = "${var.cisco_aws_instance_type}"
  cisco_azure_instance_type = "${var.cisco_azure_instance_type}"
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
  public_subnet_private_ip_address_suffix = "250.215"
  public_subnet_subnet_suffix_cidrblock =  "250.208/28"
  private_subnet_private_ip_address_suffix = "250.205"
  private_subnet_subnet_suffix_cidrblock = "250.192/28"
}

output "Remote AWS Cisco CSR VPN Router Public IP Address" {
 value = "${module.remote_aws_azure_cisco_vpn_connecter.aws_public_ip_address}"
}

output "Remote Azure Cisco CSR VPN Router Public IP Address" {
 value = "${module.remote_aws_azure_cisco_vpn_connecter.azure_public_ip_address}"
}
