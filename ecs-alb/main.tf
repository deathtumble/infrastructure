resource "aws_alb_target_group" "this" {
  name     = "${var.role}-${var.environment}"
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
    Name          = "${var.role}-${var.environment}"
    Product       = "${var.product}"
    Environment   = "${var.environment}"
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

resource "aws_ecs_cluster" "this" {
  name = "${var.role}-${var.environment}"
}

resource "aws_ecs_service" "this" {
  name            = "${var.role}-${var.environment}"
  cluster         = "${var.role}-${var.environment}"
  task_definition = "${var.task_definition}"
  desired_count   = "${var.task_status == "down" ? 0 : var.desired_task_count}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.this.arn}"
    container_name   = "${var.role}"
    container_port   = "${var.elb_instance_port}"
  }
  
  depends_on = ["null_resource.alb_listener_exists"]
}

resource "null_resource" "alb_listener_exists" {
   triggers {
      listener_arn = "${var.aws_lb_listener_default_arn}"
   }
}