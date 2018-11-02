# Public Agent Load Balancer Access
# Adminrouter Only
resource "aws_elb" "public-agent-elb-remote" {
  provider = "aws.bursted-vpc"
  name = "${data.template_file.cluster-name.rendered}-pub-agt-r-elb"

  subnets         = ["${aws_subnet.group_1_private.id}","${aws_subnet.group_2_private.id}", "${aws_subnet.group_3_private.id}"]
  security_groups = ["${aws_security_group.remote-http-https.id}", "${aws_security_group.remote-internet-outbound.id}"]
  instances       = ["${aws_instance.remote_public_agent-group-1.*.id}", "${aws_instance.remote_public_agent-group-2.*.id}", "${aws_instance.remote_public_agent-group-3.*.id}"]

  listener {
    lb_port           = 80
    instance_port     = 80
    lb_protocol       = "tcp"
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 443
    instance_port     = 443
    lb_protocol       = "tcp"
    instance_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2
    target = "HTTP:9090/_haproxy_health_check"
    interval = 5
  }

  lifecycle {
    ignore_changes = ["name"]
  }
}

output "AWS Remote Public Agent ELB Address" {
  value = "${aws_elb.public-agent-elb-remote.dns_name}"
}
