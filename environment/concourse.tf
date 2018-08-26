module "concourse_web" {
  source = "../concourse-web"
  
  docker_tag                        = "${var.concourse_docker_tag}"
  task_status                       = "${var.concourse_task_status}"
  aws_subnet_av1_id                 = "${aws_subnet.av1.id}"
  aws_subnet_av2_id                 = "${aws_subnet.av2.id}"
  concourse_password                = "${local.concourse_password}"
  concourse_postgres_password       = "${local.concourse_postgres_password}"

  globals          = "${var.globals}"
  vpc              = "${local.vpc}"
  az               = "${local.az1}"
}

