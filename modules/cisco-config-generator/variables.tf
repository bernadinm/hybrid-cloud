variable "public_ip_local_site" {}
variable "private_ip_local_site" {}
variable "public_ip_remote_site" {}
variable "private_ip_remote_site" {}
variable "private_ip_cidr_remote_site" {}

variable "remote_pre_share_key" {
  default = "cisco123"
}

variable "local_pre_share_key" {
  default = "cisco123"
}

variable "tunnel_ip_local_site" {
  default = "172.16.0.1"
}

variable "tunnel_ip_remote_site" {
  default = "172.16.0.2"
}
variable "local_hostname" {
  default = "CSR1"
}
