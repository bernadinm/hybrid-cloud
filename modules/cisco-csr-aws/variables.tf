variable "vpc_id" {
  # TODO(mbernadin): change to ""
  description = "Existing VPC to install Cisco CSR on"
  default     = "vpc-1ce5c765"
}

variable "instance_type" {
  description = "Cisco CSR Instance type. Accepts c4.<types> only"
  default = "c4.large"
}

variable "aws_region" {
  # TODO(mbernadin): change to ""
  default = "us-west-2"
}

variable "aws_profile" {
  # TODO(mbernadin): change to ""
  default = "273854932432_Mesosphere-PowerUser"
}

variable "destination_cidr" {
  description = "The CIDR block to route traffic too for the other Cisco CSR Router"
  default = ""
}

variable "destination_csr_public_ip" {
  description = "Public IP Address for destination Cisco CSR"
  default     = ""
}

variable "local_csr_public_ip" {
  description = "Public IP address of the current Cisco CSR"
  default     = ""
}

variable "terraform_dcos_destination_provider" {
  description = "The CIDR block to route traffic too for the other Cisco CSR Router"
  default = "azure"
}

variable "subnet_id" {
  # TODO(mbernadin): change to ""
  description = "selected subnet chosen for Cisco CSR on an existing subnet"
  default     = "subnet-05fa767c"
}

variable "ssh_key_name" {
  # TODO(mbernadin): change to ""
  description = "AWS Key Pair name for ssh"
  default     = "default"
}
