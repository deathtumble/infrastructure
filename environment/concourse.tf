module "concourse_web" {
  source = "../concourse-web"
  
  docker_tag                        = "${var.concourse_docker_tag}"
  task_status                       = "${var.concourse_task_status}"
  aws_db_instance_concourse_address = "${aws_db_instance.concourse.address}"
  concourse_password                = "${local.concourse_password}"
  concourse_postgres_password       = "${local.concourse_postgres_password}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

