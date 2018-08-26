locals {
  nexus_volume_id      = "${var.globals["nexus_volume_id"]}"
  grafana_volume_id    = "${var.globals["grafana_volume_id"]}"
  key_name             = "${var.globals["key_name"]}"
  root_domain_name     = "${var.globals["root_domain_name"]}"
  product              = "${var.globals["product"]}"
  environment          = "${var.globals["environment"]}"
  nameTag              = "${var.globals["nameTag"]}"
  admin_cidr           = "${var.globals["admin_cidr"]}"
  ecs_iam_role         = "${var.globals["ecs_iam_role"]}"
  
  
}


