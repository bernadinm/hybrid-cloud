variable "aws_remote_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

provider "aws" {
  alias = "bursted-vpc"
  profile = "${var.aws_profile}"
  region = "${var.aws_remote_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "bursted_region" {
  provider = "aws.bursted-vpc"
  cidr_block = "10.128.0.0/16"
  #enable_dns_hostnames = "true"

tags {
   Name = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "bursted_region" {
  provider = "aws.bursted-vpc"
  vpc_id = "${aws_vpc.bursted_region.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "group_3_internet_access" {
  provider = "aws.bursted-vpc"
   route_table_id         = "${aws_vpc.bursted_region.main_route_table_id}"
   destination_cidr_block = "0.0.0.0/0"
   gateway_id             = "${aws_internet_gateway.bursted_region.id}"
}

# A security group that allows all port access to internal vpc
resource "aws_security_group" "group_any_access_internal" {
  provider = "aws.bursted-vpc"
  name        = "cluster-security-group"
  description = "Manage all ports cluster level"
  vpc_id      = "${aws_vpc.bursted_region.id}"

 # full access internally
 ingress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["10.0.0.0/8"]
  }

 # full access internally
 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_security_group" "group_admin" {
  provider = "aws.bursted-vpc"
  name        = "admin-security-group-1"
  description = "Administrators can manage their machines"
  vpc_id      = "${aws_vpc.bursted_region.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  # http access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  # httpS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# A security group for private slave so it is accessible internally
resource "aws_security_group" "group_private_slave" {
  provider = "aws.bursted-vpc"
  name        = "private-slave-security-group"
  description = "security group for slave private"
  vpc_id      = "${aws_vpc.bursted_region.id}"

  # full access internally
  ingress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["10.0.0.0/8"]
   }

  # full access internally
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["10.0.0.0/8"]
   }
}

# A security group for public slave so it is accessible via the web
resource "aws_security_group" "group_public_slave" {
  provider    = "aws.bursted-vpc"
  name        = "public-slave-security-group"
  description = "security group for slave public"
  vpc_id      = "${aws_vpc.bursted_region.id}"

  # Allow ports within range
  ingress {
    to_port = 21
    from_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ports within range
  ingress {
    to_port = 5050
    from_port = 23
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ports within range
  ingress {
    to_port = 32000
    from_port = 5052
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ports within range
  ingress {
    to_port = 21
    from_port = 0
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ports within range
  ingress {
    to_port = 5050
    from_port = 23
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ports within range
  ingress {
    to_port = 32000
    from_port = 5052
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # full access internally
  ingress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["10.0.0.0/8"]
   }

  # full access internally
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["10.0.0.0/8"]
   }

  tags {
    KubernetesCluster = "${var.kubernetes_cluster}"
  }
}

# A security group for Admins to control access
resource "aws_security_group" "remote-http-https" {
  provider    = "aws.bursted-vpc"
  name        = "http-https-security-group"
  description = "Administrators can manage their machines"
  vpc_id      = "${aws_vpc.bursted_region.id}"

  # http access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  # httpS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }
}

# A security group for any machine to download artifacts from the web
# without this, an agent cannot get internet access to pull containers
# This does not expose any ports locally, just external access.
resource "aws_security_group" "remote-internet-outbound" {
  provider    = "aws.bursted-vpc"
  name        = "internet-outbound-only-access"
  description = "Security group to control outbound internet access only."
  vpc_id      = "${aws_vpc.bursted_region.id}"

 # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create DCOS Mesos Agent Scripts to execute
module "dcos-remote-mesos-agent" {
  source = "github.com/dcos/tf_dcos_core"
  bootstrap_private_ip = "${aws_instance.bootstrap.private_ip}"
  dcos_install_mode    = "${var.state}"
  dcos_version         = "${var.dcos_version}"
  dcos_type            = "${var.dcos_type}"
  role                 = "dcos-mesos-agent"
}

# Provide tested AMI and user from listed region startup commands
module "aws-tested-oses-bursted" {
      source   = "./modules/dcos-tested-aws-oses"
      os       = "${var.os}"
      region   = "${var.aws_remote_region}"
}

