resource "aws_elb" "this" {
  count           = "${var.elb ? 1 : 0}"
  name            = "${var.role}"
  security_groups = ["${var.elb_security_group}"]
  subnets         = ["${var.subnets}"]

  listener {
    instance_port     = "${var.elb_instance_port}"
    instance_protocol = "http"
    lb_port           = "${var.elb_port}"
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "${var.healthcheck_protocol}:${var.healthcheck_port}${var.healthcheck_path}"
    interval            = 5
  }

  tags {
    Name        = "${var.role}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
    Port        = "${var.elb_port}"
    Path        = "${var.healthcheck_path}"
    Protocol    = "${var.healthcheck_protocol}"
  }
}

resource "aws_lb_cookie_stickiness_policy" "this" {
  count                    = "${var.elb ? 1 : 0}"
  name                     = "${var.role}"
  load_balancer            = "${aws_elb.this.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_route53_record" "this" {
  count   = "${var.elb ? 1 : 0}"
  zone_id = "${var.aws_route53_record_zone_id}"
  name    = "${var.role}"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_elb.this.dns_name}"]
}

resource "aws_elb_attachment" "this" {
  count    = "${var.elb ? 1 : 0}"
  elb      = "${aws_elb.this.id}"
  instance = "${var.aws_instance_id}"
}
