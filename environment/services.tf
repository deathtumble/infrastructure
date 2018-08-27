module "aws-proxy" {
  source = "../modules/aws-proxy"
  
  aws-proxy_secret_access_key = "${local.aws-proxy_secret_access_key}"
  aws-proxy_access_id         = "${local.aws-proxy_access_id}"
  docker_tag                   = "${var.aws_proxy_docker_tag}"
  task_status                  = "${var.aws_proxy_task_status}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

module "concourse_web" {
  source = "../modules/concourse-web"
  
  docker_tag                        = "${var.concourse_docker_tag}"
  task_status                       = "${var.concourse_task_status}"
  subnet_ids                        = ["${aws_subnet.av2.id}", "${aws_subnet.av1.id}"] 
  
  concourse_password                = "${local.concourse_password}"
  concourse_postgres_password       = "${local.concourse_postgres_password}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

module "consul" {
  source = "../modules/consul"
  
  docker_tag                   = "${var.consul_docker_tag}"
  task_status                  = "${var.consul_task_status}"
  dns_ip                       = "${var.dns_ip}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

module "dashing" {
  source = "../modules/dashing"
  
  docker_tag  = "${var.dashing_docker_tag}"
  task_status = "${var.dashing_task_status}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

module "grafana" {
  source = "../modules/grafana"
  
  docker_tag                   = "${var.grafana_docker_tag}"
  task_status                  = "${var.grafana_task_status}"
  volume_id   = "${local.grafana_volume_id}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

module "nexus" {
  source = "../modules/nexus"
  
  docker_tag                   = "${var.nexus_docker_tag}"
  task_status                  = "${var.nexus_task_status}"
  volume_id                    = "${local.nexus_volume_id}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

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
