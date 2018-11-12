resource "aws_alb_target_group" "this" {
  name     = "${var.role}-${var.environment}"
  port     = "${var.elb_instance_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  deregistration_delay = "3"

  health_check = "${var.healthchecks}"

  tags {
    Name        = "${var.role}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_route53_record" "this" {
  zone_id = "${var.aws_route53_environment_zone_id}"
  name    = "${var.role}.${var.environment}.${var.root_domain_name}"
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
    values = ["${var.role}.${var.environment}.${var.root_domain_name}"]
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.role}-${var.environment}"
  cluster         = "${var.cluster_name}-${var.environment}"
  task_definition = "${var.task_definition}"
  desired_count   = "${var.task_status == "down" ? 0 : var.desired_task_count}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.this.arn}"
    container_name   = "${var.role}"
    container_port   = "${var.elb_instance_port}"
  }

  depends_on = ["null_resource.alb_listener_exists"]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = "${var.task_status == "down" ? 0 : var.desired_task_count}"
  min_capacity       = "${var.task_status == "down" ? 0 : var.desired_task_count}"
  resource_id        = "service/${var.cluster_name}-${var.environment}/${var.role}-${var.environment}"
  role_arn           = "${var.ecs_iam_role}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "null_resource" "alb_listener_exists" {
  triggers {
    listener_arn = "${var.aws_lb_listener_default_arn}"
  }
}
