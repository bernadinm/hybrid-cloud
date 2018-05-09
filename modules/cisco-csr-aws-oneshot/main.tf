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
  csr_subnet_cidr_block = "${join(".", list(element(split(".", data.aws_vpc.current_vpc.cidr_block),0), element(split(".", data.aws_vpc.current_vpc.cidr_block),1), var.subnet_suffix_cidrblock))}"
  csr_private_ip = "${join(".", list(element(split(".", data.aws_vpc.current_vpc.cidr_block),0), element(split(".", data.aws_vpc.current_vpc.cidr_block),1), var.private_ip_address_suffix))}"
}

resource "aws_subnet" "reserved_vpn" {
  vpc_id     = "${data.aws_vpc.current_vpc.id}"
  cidr_block = "${local.csr_subnet_cidr_block}"
}

data "aws_route_table" "current" {
  vpc_id    = "${var.vpc_id}"
}

resource "aws_route" "route" {
  route_table_id            = "${data.aws_route_table.current.id}"
  destination_cidr_block    = "${coalesce(var.destination_cidr, data.template_file.terraform-dcos-default-cidr.rendered)}"
  instance_id               = "${aws_instance.cisco.id}"
}

resource "aws_instance" "cisco" {
  ami                         = "${data.aws_ami_ids.cisco_csr.ids[0]}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${aws_subnet.reserved_vpn.id}"
  private_ip                  = "${local.csr_private_ip}"
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = "${var.ssh_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.sg_g1_csr1000v.id}"]
  user_data                   = "${module.cisco_site_configuration.userdata}"

  tags {
    Name = "Cisco CSR VPN Router"
  }
}


module "cisco_site_configuration" {
  source = "../cisco-config-generator"
  public_ip_local_site   = "${var.public_ip_local_site}"
  private_ip_site_one    = "${local.csr_private_ip}"
  public_ip_remote_site  = "${var.public_ip_remote_site}"
  private_ip_remote_site = "${var.private_ip_remote_site}"
  tunnel_ip_local_site   = "${var.tunnel_ip_local_site}"
  tunnel_ip_remote_site  = "${var.tunnel_ip_remote_site}"
}

data "template_file" "terraform-dcos-default-cidr" {
  template = "$${cloud == "azure" ? "10.32.0.0/16" : cloud == "gcp" ? "10.64.0.0/16" : "undefined"}"

  vars {
    cloud = "${var.terraform_dcos_destination_provider}"
  }
}

