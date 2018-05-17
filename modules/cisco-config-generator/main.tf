data "template_file" "ssh_emulator" {
  template = "${file("${path.module}/config/ssh_emulator.sh")}"

  vars {
    public_ip_local_site   = "${var.public_ip_local_site}"
    private_ip_local_site  = "${var.private_ip_local_site}"
    public_ip_remote_site  = "${var.public_ip_remote_site}"
    private_ip_remote_site = "${var.private_ip_remote_site}"
    remote_pre_share_key   = "${var.remote_pre_share_key}"
    local_pre_share_key    = "${var.local_pre_share_key}"
    tunnel_ip_local_site   = "${var.tunnel_ip_local_site}"
    tunnel_ip_remote_site  = "${var.tunnel_ip_remote_site}"
    local_hostname         = "${var.local_hostname}"
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/config/userdata.sh")}"

  vars {
    public_ip_local_site   = "${var.public_ip_local_site}"
    private_ip_local_site  = "${var.private_ip_local_site}"
    public_ip_remote_site  = "${var.public_ip_remote_site}"
    private_ip_remote_site = "${var.private_ip_remote_site}"
    remote_pre_share_key   = "${var.remote_pre_share_key}"
    local_pre_share_key    = "${var.local_pre_share_key}"
    tunnel_ip_local_site   = "${var.tunnel_ip_local_site}"
    tunnel_ip_remote_site  = "${var.tunnel_ip_remote_site}"
    local_hostname         = "${var.local_hostname}"
  }
}
