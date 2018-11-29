variable "num_of_remote_public_agent_group_1" {
  description = "DC/OS Private Agents Count"
  default = 1
}

variable "aws_group_1_remote_public_agent_az" {
  description = "AWS Default Zone"
  default     = "a"
}

resource "aws_instance" "remote_public_agent-group-1" {
  provider = "aws.bursted-vpc"
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "${module.aws-tested-oses.user}"

    # The connection will use the local SSH agent for authentication.
  }

  root_block_device {
    volume_size = "${var.aws_public_agent_instance_disk_size}"
  }

  count = "${var.num_of_remote_public_agent_group_1}"
  instance_type = "${var.aws_public_agent_instance_type}"

  # ebs_optimized = "true" # Not supported for all configurations

  tags {
   owner = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
   expiration = "${var.expiration}"
   Name =  "${data.template_file.cluster-name.rendered}-remote-pubagt-${var.aws_group_1_remote_public_agent_az}${count.index + 1}"
   cluster = "${data.template_file.cluster-name.rendered}"
  }
  # Lookup the correct AMI based on the region
  # we specified
  ami = "${module.aws-tested-oses-bursted.aws_ami}"

  # The name of our SSH keypair we created above.
  key_name = "${var.ssh_key_name}"

  # Our Security group to allow http and SSH access
  vpc_security_group_ids = ["${aws_security_group.group_public_slave.id}","${aws_security_group.group_admin.id}","${aws_security_group.group_any_access_internal.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.group_1_private.id}"

  # OS init script
  provisioner "file" {
   content = "${module.aws-tested-oses-bursted.os-setup}"
   destination = "/tmp/os-setup.sh"
   }

 # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
    provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/os-setup.sh",
      "sudo bash /tmp/os-setup.sh",
    ]
  }

  lifecycle {
    ignore_changes = ["tags.Name"]
  }
  availability_zone = "${var.aws_remote_region}${var.aws_group_1_remote_public_agent_az}"
}

# Execute generated script on agent
resource "null_resource" "remote_public_agent-group-1" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${null_resource.bootstrap.id}"
    current_ec2_instance_id = "${aws_instance.remote_public_agent-group-1.*.id[count.index]}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(aws_instance.remote_public_agent-group-1.*.public_ip, count.index)}"
    user = "${module.aws-tested-oses-bursted.user}"
  }

  count = "${var.num_of_remote_public_agent_group_1}"

  # Generate and upload Agent script to node
  provisioner "file" {
    content     = "${module.dcos-mesos-agent-public.script}"
    destination = "run.sh"
  }

  # Wait for bootstrapnode to be ready
  provisioner "remote-exec" {
    inline = [
     "until $(curl --output /dev/null --silent --head --fail http://${aws_instance.bootstrap.private_ip}/dcos_install.sh); do printf 'waiting for bootstrap node to serve...'; sleep 20; done"
    ]
  }

  # Install Slave Node
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x run.sh",
      "sudo ./run.sh",
    ]
  }

  # Mesos poststart check workaround. Engineering JIRA filed to Mesosphere team to fix.  
  provisioner "remote-exec" {
    inline = [
     "sudo sed -i.bak '131 s/1s/5s/' /opt/mesosphere/packages/dcos-config--setup*/etc/dcos-diagnostics-runner-config.json dcos-diagnostics-runner-config.json &> /dev/null || true",
     "sudo sed -i.bak '162 s/1s/10s/' /opt/mesosphere/packages/dcos-config--setup*/etc/dcos-diagnostics-runner-config.json dcos-diagnostics-runner-config.json &> /dev/null || true"
    ]
  }

}
#output "Public Agent Public IP Address" {
#  value = ["${aws_instance.remote_public_agent-group-1.*.public_ip}"]
#}
