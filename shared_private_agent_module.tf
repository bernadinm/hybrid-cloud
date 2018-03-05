# Create DCOS Mesos Agent Scripts to execute
module "dcos-mesos-agent" {
  source = "git@github.com:amitaekbote/terraform-dcos-enterprise//tf_dcos_core?ref=addnode"
  bootstrap_private_ip = "${aws_instance.bootstrap.private_ip}"
  dcos_install_mode    = "${var.state}"
  dcos_version         = "${var.dcos_version}"
  role                 = "dcos-mesos-agent"
}

