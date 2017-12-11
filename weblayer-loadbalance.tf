resource "aws_security_group" "weblayerui" {
  name        = "weblayerui"
  
  description = "weblayerui security group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "consului-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "consul"
  }
}

resource "aws_elb" "weblayerui" {
  name            = "weblayerui"
  security_groups = ["${aws_security_group.weblayerui.id}"]
  subnets = ["${aws_subnet.weblayer.id}"]
  depends_on = ["aws_security_group.weblayerui"]
  
  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }  

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8500/v1/agent/checks"
    interval            = 30
  }
}

resource "aws_route53_record" "weblayer" {
	zone_id = "${aws_route53_zone.poc-poc.zone_id}"
	name    = "www."
    type    = "A"
    depends_on = ["aws_route53_zone.poc-poc"]

	alias {
		 name = "${aws_elb.weblayerui.dns_name}"
		 zone_id = "${aws_elb.weblayerui.zone_id}"
		 evaluate_target_health = "false"
	}
}