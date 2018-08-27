locals {
  root_domain_name     = "${var.globals["root_domain_name"]}"
  product              = "${var.globals["product"]}"
  environment          = "${var.globals["environment"]}"
  nameTag              = "${var.globals["nameTag"]}"
  admin_cidr           = "${var.globals["admin_cidr"]}"
  ecs_iam_role         = "${var.globals["ecs_iam_role"]}"
}

