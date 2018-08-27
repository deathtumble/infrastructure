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

