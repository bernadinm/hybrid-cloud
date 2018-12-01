# Remote Private agent instance deploy
variable "aws_group_3_remote_agent_az" { 
  default = "c"
}

variable "num_of_remote_private_agents_group_3" {
  default = "1"
}

# Create a subnet to launch slave private node into
resource "aws_subnet" "group_3_private" {
  provider = "aws.bursted-vpc"
  vpc_id                  = "${aws_vpc.bursted_region.id}"
  cidr_block              = "10.128.16.0/22"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_remote_region}${var.aws_group_3_remote_agent_az}"
}

resource "aws_instance" "group_3_remote_agent" {
  provider = "aws.bursted-vpc"
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "${module.aws-tested-oses-bursted.user}"

    # The connection will use the local SSH agent for authentication.
  }

  root_block_device {
    volume_size = "${var.instance_disk_size}"
  }

  count = "${var.num_of_remote_private_agents_group_3}"
  instance_type = "${var.aws_agent_instance_type}"

  tags {
   owner = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
   expiration = "${var.expiration}"
   Name =  "${data.template_file.cluster-name.rendered}-remote-pvtagt-${count.index + 1}"
   cluster = "${data.template_file.cluster-name.rendered}"
  }
  # Lookup the correct AMI based on the region
  # we specified
  ami = "${module.aws-tested-oses-bursted.aws_ami}"

  # The name of our SSH keypair we created above.
  key_name = "${var.ssh_key_name}"

  # Our Security group to allow http and SSH access
  vpc_security_group_ids = ["${aws_security_group.group_private_slave.id}","${aws_security_group.group_admin.id}","${aws_security_group.group_any_access_internal.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.group_3_private.id}"

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
  availability_zone = "${var.aws_remote_region}${var.aws_group_3_remote_agent_az}"
}

# Execute generated script on agent
resource "null_resource" "group_3_remote_agent" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${null_resource.bootstrap.id}"
    current_ec2_instance_id = "${aws_instance.group_3_remote_agent.*.id[count.index]}"
  }
  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(aws_instance.group_3_remote_agent.*.public_ip, count.index)}"
    user = "${module.aws-tested-oses-bursted.user}"
  }

  count = "${var.num_of_remote_private_agents_group_3}"

  # Generate and upload Agent script to node
  provisioner "file" {
    content     = "${module.dcos-remote-mesos-agent.script}"
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
     "sudo sed -i.bak '131 s/1s/10s/' /opt/mesosphere/packages/dcos-config--setup*/etc/dcos-diagnostics-runner-config.json &> /dev/null || true",
     "sudo sed -i.bak '140 s/1s/10s/' /opt/mesosphere/packages/dcos-config--setup*/etc/dcos-check-config.json &> /dev/null || true",
     "sudo sed -i.bak '162 s/1s/10s/' /opt/mesosphere/packages/dcos-config--setup*/etc/dcos-diagnostics-runner-config.json &> /dev/null || true"
    ]
  }
 depends_on = ["aws_vpc_peering_connection_accepter.peer"]
}

#output "Remote Private Agent Public IP Address" {
#  value = "${join(", ", aws_instance.group_3_remote_agent.*.public_ip)}"
#}
