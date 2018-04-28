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

resource "aws_alb_listener" "this" {
  load_balancer_arn = "${var.aws_alb_arn}"
  port              = "${var.elb_instance_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.this.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "this" {
  target_group_arn = "${aws_alb_target_group.this.arn}"
  target_id        = "${aws_instance.this.id}"
  port             = "${var.elb_instance_port}"
}

