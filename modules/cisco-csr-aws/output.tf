output "cisco_csr_ami" {
  value = "${data.aws_ami_ids.cisco_csr.ids}"
}

output "destination_cidr" {
  value = "${data.template_file.terraform-dcos-default-cidr.rendered}"
}

output "cisco_elastic_public_ip_address" {
  value = "${aws_eip.csr_public_ip.public_ip}"
}

output "cisco_ssh_user" {
  value = "ec2-user"
}
