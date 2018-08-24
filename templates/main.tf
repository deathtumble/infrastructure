module "murray" {
  source = "../environment"

  aws_route53_zone_id  = "${var.aws_route53_zone_id}"
  nexus_volume_id      = "${var.nexus_volume_id}"
  monitoring_volume_id = "${var.monitoring_volume_id}"
  key_name             = "${var.key_name}"
  root_domain_name     = "${var.root_domain_name}"
  product              = "${var.product}"
  environment          = "${var.environment}"
  nameTag              = "${var.nameTag}"
  admin_cidr           = "${var.admin_cidr}"

  concourse_task_status  = "${var.concourse_task_status}"
  monitoring_task_status = "${var.monitoring_task_status}"
  dashing_task_status    = "${var.dashing_task_status}"
  nexus_task_status      = "${var.nexus_task_status}"

  concourse_postgres_password            = "${var.concourse_postgres_password}"
  concourse_password                     = "${var.concourse_password}"
  aws-proxy_access_id                    = "${var.aws-proxy_access_id}"
  aws-proxy_secret_access_key            = "${var.aws-proxy_secret_access_key}"
  concourse_tsa_host_key_value           = "${var.concourse_tsa_host_key_value}"
  concourse_tsa_authorized_keys_value    = "${var.concourse_tsa_authorized_keys_value}"
  concourse_session_signing_key_value    = "${var.concourse_session_signing_key_value}"
  concourse_tsa_public_key_value         = "${var.concourse_tsa_public_key_value}"
  concourse_tsa_worker_private_key_value = "${var.concourse_tsa_worker_private_key_value}"
}

terraform {
  backend "s3" {
    bucket = "terraform.backend.urbanfortress.uk"
    key    = "poc/murray"
    region = "eu-west-1"
  }
}
