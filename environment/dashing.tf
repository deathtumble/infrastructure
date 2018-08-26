module "dashing" {
  source = "../dashing"
  
  docker_tag                   = "${var.dashing_docker_tag}"
  task_status                  = "${var.dashing_task_status}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

