resource "aws_alb_target_group" "consul" {
  name     = "consul-${local.environment}"
  port     = "8500"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/v1/agent/checks"
    protocol            = "HTTP"
    port                = "8500"
    interval            = 5
  }

  tags {
    Name          = "consul-${local.environment}"
    Product       = "${local.product}"
    Environment   = "${local.environment}"
  }
}

resource "aws_route53_record" "consul" {
  zone_id = "${aws_route53_zone.environment.zone_id}"
  name    = "consul.${local.environment}.${local.root_domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = ["${aws_alb.default.dns_name}"]
}

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = "${aws_alb_listener.default.arn}"
  priority     = "94"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.consul.arn}"
  }

  condition {
    field  = "host-header"
    values = ["consul.${local.environment}.${local.root_domain_name}"]
  }
}
resource "aws_alb_target_group_attachment" "consul" {
  count    = "${var.consul_server_count}"
  target_group_arn = "${aws_alb_target_group.consul.arn}"
  target_id        = "${aws_instance.consul.*.id[count.index]}"
  port             = "8500"
}

