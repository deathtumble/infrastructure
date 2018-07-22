resource "aws_alb_target_group" "consul" {
  name     = "consul-${var.environment}"
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
    Name          = "consul-${var.environment}"
    Product       = "${var.product}"
    Environment   = "${var.environment}"
  }
}

resource "aws_alb_listener" "consul" {
  load_balancer_arn = "${aws_alb.default.arn}"
  port              = "8500"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.consul.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "consul-server" {
  count    = "${var.consul_server_count}"
  target_group_arn = "${aws_alb_target_group.consul.arn}"
  target_id        = "${aws_instance.consul-server.*.id[count.index]}"
  port             = "8500"
}

resource "aws_alb_target_group_attachment" "consul-leader" {
  target_group_arn = "${aws_alb_target_group.consul.arn}"
  target_id        = "${aws_instance.consul-leader.id}"
  port             = "8500"
}
