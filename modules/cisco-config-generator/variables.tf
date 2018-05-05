variable "public_ip_site_one" {}
variable "private_ip_site_one" {}
variable "username_site_one" {}
variable "password_site_one" { default = "" }
variable "public_ip_site_two" {}
variable "private_ip_site_two" {}
variable "username_site_two" {}
variable "password_site_two" { default = "" }

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
variable "hostname_site_two" {
  default = "CSR2"
}
variable "hostname_site_one" {
  default = "CSR1"
}
