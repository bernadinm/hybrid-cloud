variable "vpc_id" {
  default = "vpc-e9904992"
}

variable "subnet_id" {
  default = "sg-b4a946c2"
}

variable "vpc_cidr_block" {
  default =  "10.0.0.0/16"
}

variable "cluster_num" {
  default = "0"
  description = "the cluster number within the same vpc number. Allows to run multiple clusters within a single vpc."
}
