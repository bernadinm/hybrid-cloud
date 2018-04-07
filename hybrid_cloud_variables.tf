variable "vpc_id" {
  default = "vpc-9d0260e6"
}

variable "aws_sg" {
  default = "sg-fbd226b2"
}

variable "azure_rg_name" {
  default = "Hybrid-Demo2"
}

variable "azure_full_subnet_id" {
  default = "/subscriptions/6bfddfe6-078b-4a9d-86ff-52e86464efe0/resourceGroups/Hybrid-Demo2/providers/Microsoft.Network/virtualNetworks/Hybrid-Demo2/subnets/Hybrid2-Internal"
}

variable "azure_region" {
  description = "Azure region to launch servers."
  default     = "UK South"
}

variable "vpc_cidr_block" {
  default =  "10.0.0.0/16"
}
