locals {
  aws_route53_zon_id = "${var.globals["aws_route53_zone_id"]}"
  nexus_volume_id = "${var.globals["nexus_volume_id"]}"
  monitoring_volume_id = "${var.globals["monitoring_volume_id"]}"
  key_name = "${var.globals["key_name"]}"
  root_domain_name = "${var.globals["root_domain_name"]}"
  product = "${var.globals["product"]}"
  environment = "${var.globals["environment"]}"
  nameTag = "${var.globals["nameTag"]}"
  admin_cidr = "${var.globals["admin_cidr"]}"
}