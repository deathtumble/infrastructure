module "prometheus" {
  source = "../modules/prometheus"
  
  prometheus_secret_access_key = "${local.prometheus_secret_access_key}"
  prometheus_access_id         = "${local.prometheus_access_id}"
  docker_tag                   = "${var.prometheus_docker_tag}"
  task_status                  = "${var.prometheus_task_status}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

