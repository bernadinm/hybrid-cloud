# Create DCOS Mesos Agent Scripts to execute
module "azure-dcos-mesos-agent-public" {
  source = "git@github.com:mesosphere/enterprise-terraform-dcos//tf_dcos_core"
  bootstrap_private_ip = "${azurerm_network_interface.bootstrap_nic.private_ip_address}"
  dcos_install_mode    = "${var.state}"
  dcos_version         = "${var.dcos_version}"
  role                 = "dcos-mesos-agent-public"
}

