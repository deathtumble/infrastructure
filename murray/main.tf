module "environment" {
  source = "../environment"

  context = var.context	
  secrets = var.secrets

  concourse_task_status = var.concourse_task_status
  grafana_task_status   = var.grafana_task_status
  dashing_task_status   = var.dashing_task_status
  nexus_task_status     = var.nexus_task_status
  consul_task_status    = var.consul_task_status

  elasticsearch_docker_tag = var.elasticsearch_docker_tag
  logstash_docker_tag      = var.logstash_docker_tag
}

terraform {
  backend "s3" {
    bucket = "terraform.backend.urbanfortress.uk"
    key    = "poc/murray"
    region = "eu-west-1"
  }
}

