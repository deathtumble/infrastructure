locals {
  efs_id               = "${var.globals["efs_id"]}"
  nexus_volume_id      = "${var.globals["nexus_volume_id"]}"
  grafana_volume_id    = "${var.globals["grafana_volume_id"]}"
  key_name             = "${var.globals["key_name"]}"
  root_domain_name     = "${var.globals["root_domain_name"]}"
  product              = "${var.globals["product"]}"
  environment          = "${var.globals["environment"]}"
  nameTag              = "${var.globals["nameTag"]}"
  admin_cidr           = "${var.globals["admin_cidr"]}"
  ecs_iam_role         = "${var.globals["ecs_iam_role"]}"
  
  region                          = "${var.vpc["region"]}"
  aws_security_group_os_id        = "${var.vpc["aws_security_group_os_id"]}"
  aws_route53_environment_zone_id = "${var.vpc["aws_route53_environment_zone_id"]}"
  aws_lb_listener_default_arn     = "${var.vpc["aws_lb_listener_default_arn"]}"
  aws_alb_default_dns_name        = "${var.vpc["aws_alb_default_dns_name"]}"
  vpc_id                          = "${var.vpc["vpc_id"]}"
  ecs_ami_id                      = "${var.vpc["ecs_ami_id"]}"
  vpc_cidr                        = "${var.vpc["vpc_cidr"]}"
  
  availability_zone               = "${var.az["availability_zone"]}"
  subnet_id                       = "${var.az["subnet_id"]}"
}


