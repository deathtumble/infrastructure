module "nexus" {
  source = "../modules/nexus"
  
  docker_tag                   = "${var.nexus_docker_tag}"
  task_status                  = "${var.nexus_task_status}"
  volume_id                    = "${local.nexus_volume_id}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

