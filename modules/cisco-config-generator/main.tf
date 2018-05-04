data "template_file" "site_one" {
  template = "${file("${path.module}/config/site_one_setup.sh")}"

  vars {
    public_ip_site_one  = "${var.public_ip_site_one}"
    private_ip_site_one = "${var.private_ip_site_one}"
    username_site_one   = "${var.username_site_one}"
    public_ip_site_two  = "${var.public_ip_site_two}"
    private_ip_site_two = "${var.private_ip_site_two}"
    username_site_two   = "${var.username_site_two}"
    password_site_two   = "${var.password_site_two}"
    remote_pre_share_key= "${var.remote_pre_share_key}"
    local_pre_share_key = "${var.local_pre_share_key}"
    tunnel_ip_site_one  = "${var.tunnel_ip_site_one}"
    tunnel_ip_site_two  = "${var.tunnel_ip_site_two}"
    hostname_site_two   = "${var.hostname_site_two}"
    hostname_site_one   = "${var.hostname_site_one}"
  }
}

data "template_file" "site_two" {
  template = "${file("${path.module}/config/site_two_setup.sh")}"

  vars {
    public_ip_site_one  = "${var.public_ip_site_one}"
    private_ip_site_one = "${var.private_ip_site_one}"
    username_site_one   = "${var.username_site_one}"
    public_ip_site_two  = "${var.public_ip_site_two}"
    private_ip_site_two = "${var.private_ip_site_two}"
    username_site_two   = "${var.username_site_two}"
    password_site_two   = "${var.password_site_two}"
    remote_pre_share_key= "${var.remote_pre_share_key}"
    local_pre_share_key = "${var.local_pre_share_key}"
    tunnel_ip_site_one  = "${var.tunnel_ip_site_one}"
    tunnel_ip_site_two  = "${var.tunnel_ip_site_two}"
    hostname_site_two   = "${var.hostname_site_two}"
    hostname_site_one   = "${var.hostname_site_one}"
  }
}
