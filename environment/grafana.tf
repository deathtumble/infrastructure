module "grafana" {
  source = "../modules/grafana"
  
  docker_tag                   = "${var.grafana_docker_tag}"
  task_status                  = "${var.grafana_task_status}"
  volume_id   = "${local.grafana_volume_id}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

