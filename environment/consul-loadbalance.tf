resource "aws_lb_cookie_stickiness_policy" "consului" {
  name                     = "consului"
  load_balancer            = "${aws_elb.consului.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_elb" "consului" {
  name            = "consului"
  security_groups = ["${aws_security_group.consului.id}"]
  subnets         = ["${aws_subnet.av1.id}"]
  depends_on      = ["aws_security_group.consului"]

  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8500/v1/agent/checks"
    interval            = 30
  }
}

resource "aws_route53_record" "consul" {
  zone_id = "${var.aws_route53_zone_id}"
  name    = "consul"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_elb.consului.dns_name}"]
}

resource "aws_security_group" "consului" {
  name = "consului"

  description = "consului security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${concat(var.monitoring_cidrs, list(var.admin_cidr))}"
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = "${concat(var.monitoring_cidrs, list(var.admin_cidr))}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "consului-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
    Layer       = "consul"
  }
}

