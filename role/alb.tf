resource "aws_alb_target_group" "this" {
  name     = "${var.role}-${local.environment}"
  port     = "${var.elb_instance_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "${var.healthcheck_path}"
    protocol            = "${var.healthcheck_protocol}"
    port                = "${var.elb_instance_port}"
    interval            = 5
  }

  tags {
    Name          = "${var.role}-${local.environment}"
    Product       = "${local.product}"
    Environment   = "${local.environment}"
  }
}

resource "aws_route53_record" "this" {
  zone_id = "${var.aws_route53_environment_zone_id}"
  name    = "${var.role}.${local.environment}.${local.root_domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = ["${var.aws_alb_default_dns_name}"]
}

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = "${var.aws_lb_listener_default_arn}"
  priority     = "${var.aws_lb_listener_rule_priority}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.this.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.role}.${local.environment}.${local.root_domain_name}"]
  }
}
