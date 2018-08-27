module "vpc" {
  source = "../modules/vpc"
  vpc_cidr = "${var.vpc_cidr}"
  dns_ip = "${var.dns_ip}"
  aws_security_group_alb_id = "${aws_security_group.alb.id}"
  globals          = "${var.globals}"
}