output "destination_cidr" {
  value = "${data.template_file.terraform-dcos-default-cidr.rendered}"
}

output "cisco_static_public_ip_address" {
  value = "${data.azurerm_public_ip.cisco.ip_address}"
}

output "cisco_ssh_user" {
  value = "${var.cisco_user}"
}
