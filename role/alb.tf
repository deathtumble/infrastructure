resource "aws_alb_listener_rule" "this" {
  listener_arn = "${var.listener_arn}"
  priority     = "${var.alb_priority}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.this.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.role}-${var.product}-${var.environment}.${var.root_domain_name}"]
  }
}

resource "aws_alb_target_group" "this" {
  name     = "${var.role}"
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
}

resource "aws_alb_target_group_attachment" "this" {
  target_group_arn = "${aws_alb_target_group.this.arn}"
  target_id        = "${aws_instance.this.id}"
  port             = "${var.elb_instance_port}"
}

resource "aws_route53_record" "environment" {
  count   = "1"
  zone_id = "${var.aws_route53_zone_id}"
  name    = "${var.role}-${var.product}-${var.environment}"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.aws_alb_default_dns_name}"]
}
