module "environment" {
  source = "../environment"
  
  globals = "${var.globals}"
  
  concourse_task_status = "${var.concourse_task_status}"
  monitoring_task_status = "${var.monitoring_task_status}"
  dashing_task_status = "${var.dashing_task_status}"
  nexus_task_status = "${var.nexus_task_status}"
  
  secrets = "${var.secrets}"
  
}

terraform {
  backend "s3" {
    bucket = "terraform.backend.urbanfortress.uk"
    key = "poc/murray"
    region = "eu-west-1"
  }
}
