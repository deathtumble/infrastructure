module "prometheus" {
  source = "../prometheus"
  
  region                          = "${var.region}"
  aws_security_group_os_id        = "${aws_security_group.os.id}"
  aws_route53_environment_zone_id = "${aws_route53_zone.environment.zone_id}"
  aws_lb_listener_default_arn     = "${aws_alb_listener.default.arn}"
  aws_alb_default_dns_name        = "${aws_alb.default.dns_name}"
  vpc_id                          = "${aws_vpc.default.id}"
  ecs_ami_id                      = "${var.ecs_ami_id}"
  availability_zone               = "${var.availability_zone_1}"
  subnet_id                       = "${aws_subnet.av1.id}"

  prometheus_secret_access_key = "${local.prometheus_secret_access_key}"
  prometheus_access_id         = "${local.prometheus_access_id}"
  docker_tag                   = "${var.prometheus_docker_tag}"
  task_status                  = "${var.prometheus_task_status}"

  globals          = "${var.globals}"
}

