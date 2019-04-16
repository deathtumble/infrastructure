locals {
  key_name             = "${var.globals["key_name"]}"
  root_domain_name     = "${var.globals["root_domain_name"]}"
  product              = "${var.globals["product"]}"
  environment          = "${var.globals["environment"]}"
  nameTag              = "${var.globals["nameTag"]}"
  admin_cidr           = "${var.globals["admin_cidr"]}"
  ecs_iam_role         = "${var.globals["ecs_iam_role"]}"
  efs_id               = "${var.globals["efs_id"]}"

  concourse_postgres_password            = "${var.secrets["concourse_postgres_password"]}"
  concourse_password                     = "${var.secrets["concourse_password"]}"
 
  vpc = {
      region                          = "${var.region}"
      aws_security_group_os_id        = "${aws_security_group.os.id}"
      aws_route53_environment_zone_id = "${module.vpc.aws_route53_environment_zone_id}"
      aws_lb_listener_default_arn     = "${module.vpc.aws_lb_listener_default_arn}"
      aws_alb_default_dns_name        = "${module.vpc.aws_alb_default_dns_name}"
      vpc_id                          = "${module.vpc.vpc_id}"
      ecs_ami_id                      = "${var.ecs_ami_id}"
      vpc_cidr                        = "${var.vpc_cidr}"
  }
  
  az1 = {
      availability_zone               = "${module.vpc.az1_availability_zone}"
      subnet_id                       = "${module.vpc.az1_subnet_id}"
  }
}
