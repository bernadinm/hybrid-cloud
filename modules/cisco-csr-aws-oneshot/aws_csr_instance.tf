# Specify the provider and access details
provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}

data "aws_ami_ids" "cisco_csr" {
  # Retrieves the AMI within the region that the VPC is created
  # Cost: It takes roughly ~50 seconds to perform this query of the ami
  # Owner: Cisco 
  owners = ["679593333241"]

  filter {
    name   = "name"
    values = ["cisco-ic_CSR_*-AMI-SEC-HVM-*"]
  }
  filter {
    name   = "description"
    values = ["cisco-ic_CSR_*-AMI-SEC-HVM"]
  }
  filter {
    name   = "is-public"
    values = ["true"]
  }
}

data "aws_vpc" "current" {
  id = "${var.vpc_id}"
}

locals {
  aws_csr_subnet_cidr_block = "${join(".", list(element(split(".", data.aws_vpc.current.cidr_block),0), element(split(".", data.aws_vpc.current.cidr_block),1), var.subnet_suffix_cidrblock))}"
  aws_csr_private_ip = "${join(".", list(element(split(".", data.aws_vpc.current.cidr_block),0), element(split(".", data.aws_vpc.current.cidr_block),1), var.private_ip_address_suffix))}"
}

resource "aws_subnet" "reserved_vpn" {
  vpc_id     = "${data.aws_vpc.current.id}"
  cidr_block = "${local.aws_csr_subnet_cidr_block}"
}

data "aws_route_table" "current" {
  vpc_id    = "${var.vpc_id}"
}

resource "aws_route" "route" {
  route_table_id            = "${data.aws_route_table.current.id}"
  destination_cidr_block    = "${coalesce(var.destination_cidr, data.template_file.aws-terraform-dcos-default-cidr.rendered)}"
  instance_id               = "${aws_instance.cisco.id}"
}

resource "aws_eip" "csr" {
  vpc = true
}

resource "aws_eip_association" "csr" {
  allocation_id = "${aws_eip.csr.id}"
  instance_id   = "${aws_instance.cisco.id}"
}

resource "aws_instance" "cisco" {
  ami                         = "${data.aws_ami_ids.cisco_csr.ids[0]}"
  instance_type               = "${var.aws_instance_type}"
  subnet_id                   = "${aws_subnet.reserved_vpn.id}"
  private_ip                  = "${local.aws_csr_private_ip}"
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = "${var.ssh_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.sg_g1_csr1000v.id}"]
  user_data                   = "${module.aws_csr_userdata.userdata}"

  tags {
    Name = "Cisco CSR VPN Router"
  }
}

module "aws_csr_userdata" {
  source = "../cisco-config-generator"
  public_ip_local_site   = "${coalesce(var.public_ip_local_site, aws_eip.csr.public_ip)}"
  private_ip_local_site  = "${local.aws_csr_private_ip}"
  public_ip_remote_site  = "${coalesce(var.public_ip_remote_site, azurerm_public_ip.cisco.ip_address)}"
  private_ip_remote_site = "${coalesce(var.private_ip_remote_site, local.azure_csr_private_ip)}"
  tunnel_ip_local_site   = "${var.tunnel_ip_local_site}"
  tunnel_ip_remote_site  = "${var.tunnel_ip_remote_site}"
  local_hostname         = "${var.local_hostname}"
}

data "template_file" "aws-terraform-dcos-default-cidr" {
  template = "$${cloud == "azure" ? "10.32.0.0/16" : cloud == "gcp" ? "10.64.0.0/16" : "undefined"}"

  vars {
    cloud = "${var.remote_terraform_dcos_destination_provider}"
  }
}

