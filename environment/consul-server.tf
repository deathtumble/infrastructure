module "consul" {
  source = "../modules/consul"
  
  docker_tag                   = "${var.consul_docker_tag}"
  task_status                  = "${var.consul_task_status}"
  dns_ip                       = "${var.dns_ip}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

