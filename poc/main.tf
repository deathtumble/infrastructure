module "murray" {
  source = "../environment"
  
  aws_route53_zone_id = "${var.aws_route53_zone_id}"
  nexus_volume_id = "${var.nexus_volume_id}"
  monitoring_volume_id = "${var.monitoring_volume_id}"
  key_name = "${var.key_name}"
  root_domain_name = "${var.root_domain_name}"
  product = "${var.product}"
  environment = "${var.environment}"
  nameTag = "${var.nameTag}"
  admin_cidr = "${var.admin_cidr}"
  ecs_ami_id = "${var.ecs_ami_id}"
  aws_proxy_docker_tag = "${var.aws_proxy_docker_tag}"
  dashing_docker_tag = "${var.dashing_docker_tag}"
  consul_docker_tag = "${var.consul_docker_tag}"
  concourse_docker_tag = "${var.concourse_docker_tag}"
  collectd_docker_tag = "${var.collectd_docker_tag}"
  hubot_slack_token = "${var.hubot_slack_token}"
  concourse_postgres_password = "${var.concourse_postgres_password}"
  concourse_password = "${var.concourse_password}"
  higgins_grafana_api_key = "${var.higgins_grafana_api_key}"
  higgins_grafana_s3_access_key_id = "${var.higgins_grafana_s3_access_key_id}"
  higgin_grafana_s3_secret_access_key = "${var.higgin_grafana_s3_secret_access_key}"
  higgin_grafana_s3_prefix = "${var.higgin_grafana_s3_prefix}"
  higgin_grafana_s3_bucket = "${var.higgin_grafana_s3_bucket}"
  aws-proxy_access_id = "${var.aws-proxy_access_id}"
  aws-proxy_secret_access_key = "${var.aws-proxy_secret_access_key}"
  concourse_tsa_host_key_value = "${var.concourse_tsa_host_key_value}"
  concourse_tsa_authorized_keys_value = "${var.concourse_tsa_authorized_keys_value}"
  concourse_session_signing_key_value = "${var.concourse_session_signing_key_value}"
  concourse_tsa_public_key_value = "${var.concourse_tsa_public_key_value}"
  concourse_tsa_worker_private_key_value = "${var.concourse_tsa_worker_private_key_value}"
}

terraform {
  backend "s3" {
    bucket = "terraform.backend.urbanfortress.uk"
    key = "poc/murray"
    region = "eu-west-1"
  }
}
