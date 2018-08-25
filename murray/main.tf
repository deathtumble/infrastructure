module "environment" {
  source = "../environment"

  globals = "${var.globals}"
  secrets = "${var.secrets}"

  concourse_task_status  = "${var.concourse_task_status}"
  grafana_task_status    = "${var.grafana_task_status}"
  dashing_task_status    = "${var.dashing_task_status}"
  nexus_task_status      = "${var.nexus_task_status}"
  consul_task_status     = "${var.consul_task_status}"
}

terraform {
  backend "s3" {
    bucket = "terraform.backend.urbanfortress.uk"
    key    = "poc/murray"
    region = "eu-west-1"
  }
}
