variable "vpc_id" {
  description = "Existing VPC to install Cisco CSR on"
  default     = ""
}

variable "instance_type" {
  description = "Cisco CSR Instance type. Accepts c4.<types> only"
  default = "c4.large"
}

variable "aws_region" {
  default = ""
}

variable "aws_profile" {
  default = ""
}

variables "private_ip_address_suffix" {
  description = "Cisco CSR reserved ip address within existing VNet/VPC. i.e X.X.250.250"
  default = "250.250"
}

variables "subnet_suffix_cidrblock" {
  description = "Cisco CSR reserved subnet address cidr block within existing VNet/VPC. i.e X.X.250.240/28"
  default = "250.240/28"
}

variable "destination_cidr" {
  description = "The CIDR block to route traffic too for the other Cisco CSR Router"
  default = ""
}

variable "destination_csr_public_ip" {
  description = "Public IP Address for destination Cisco CSR"
  default     = ""
}

variable "terraform_dcos_destination_provider" {
  description = "The CIDR block to route traffic too for the other Cisco CSR Router"
  default = "aws"
}

variable "public_ip_site_one" {}
variable "public_ip_site_two" {}
variable "private_ip_site_two" {}

variable "remote_pre_share_key" {
  default = "cisco123"
}

variable "local_pre_share_key" {
  default = "cisco123"
}

variable "tunnel_ip_site_one" {
  default = "172.16.0.1"
}
variable "tunnel_ip_site_two" {
  default = "172.16.0.2"
}
variable "local_hostname" {
  default = "CSR1"
}
