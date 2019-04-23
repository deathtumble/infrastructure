module "aws-proxy" {
  source = "../modules/aws-proxy"

  docker_tag  = var.aws_proxy_docker_tag
  task_status = var.aws_proxy_task_status

  context = var.context
  vpc_id  = module.vpc.vpc_id
  ecs_iam_role = var.ecs_iam_role
  aws_route53_environment_zone_id = module.vpc.aws_route53_environment_zone_id
  aws_lb_listener_default_arn     = module.vpc.aws_lb_listener_default_arn
  aws_alb_default_dns_name        = module.vpc.aws_alb_default_dns_name
}

module "concourse_web" {
  source = "../modules/concourse-web"

  docker_tag  = var.concourse_docker_tag
  task_status = var.concourse_task_status
  subnet_ids  = [module.vpc.az1_subnet_id, module.vpc.az2_subnet_id]

  concourse_password          = var.secrets.concourse_password
  concourse_postgres_password = var.secrets.concourse_postgres_password

  context = var.context
  vpc_id  = module.vpc.vpc_id
  ecs_iam_role = var.ecs_iam_role
  aws_route53_environment_zone_id = module.vpc.aws_route53_environment_zone_id
  aws_lb_listener_default_arn     = module.vpc.aws_lb_listener_default_arn
  aws_alb_default_dns_name        = module.vpc.aws_alb_default_dns_name
}

module "consul" {
  source = "../modules/consul"

  docker_tag  = var.consul_docker_tag
  task_status = var.consul_task_status

  context = var.context
  vpc = var.context.vpcs["primary"]
  vpc_id  = module.vpc.vpc_id
  
  aws_security_group_os_id = aws_security_group.os.id
  ecs_iam_role = var.ecs_iam_role
  aws_route53_environment_zone_id = module.vpc.aws_route53_environment_zone_id
  aws_lb_listener_default_arn     = module.vpc.aws_lb_listener_default_arn
  aws_alb_default_dns_name        = module.vpc.aws_alb_default_dns_name
}

module "dashing" {
  source = "../modules/dashing"

  docker_tag  = var.dashing_docker_tag
  task_status = var.dashing_task_status

  context = var.context
  vpc_id  = module.vpc.vpc_id
  ecs_iam_role = var.ecs_iam_role
  aws_route53_environment_zone_id = module.vpc.aws_route53_environment_zone_id
  aws_lb_listener_default_arn     = module.vpc.aws_lb_listener_default_arn
  aws_alb_default_dns_name        = module.vpc.aws_alb_default_dns_name
}

module "grafana" {
  source = "../modules/grafana"

  docker_tag  = var.grafana_docker_tag
  task_status = var.grafana_task_status

  context = var.context
  vpc_id  = module.vpc.vpc_id
  ecs_iam_role = var.ecs_iam_role
  aws_route53_environment_zone_id = module.vpc.aws_route53_environment_zone_id
  aws_lb_listener_default_arn     = module.vpc.aws_lb_listener_default_arn
  aws_alb_default_dns_name        = module.vpc.aws_alb_default_dns_name
}

module "nexus" {
  source = "../modules/nexus"

  docker_tag  = var.nexus_docker_tag
  task_status = var.nexus_task_status

  context = var.context
  vpc_id  = module.vpc.vpc_id
  ecs_iam_role = var.ecs_iam_role
  aws_route53_environment_zone_id = module.vpc.aws_route53_environment_zone_id
  aws_lb_listener_default_arn     = module.vpc.aws_lb_listener_default_arn
  aws_alb_default_dns_name        = module.vpc.aws_alb_default_dns_name
}

module "prometheus" {
  source = "../modules/prometheus"

  docker_tag  = var.prometheus_docker_tag
  task_status = var.prometheus_task_status

  context = var.context
  vpc_id  = module.vpc.vpc_id
  ecs_iam_role = var.ecs_iam_role
  aws_route53_environment_zone_id = module.vpc.aws_route53_environment_zone_id
  aws_lb_listener_default_arn     = module.vpc.aws_lb_listener_default_arn
  aws_alb_default_dns_name        = module.vpc.aws_alb_default_dns_name
}

resource "aws_route53_record" "ssh" {
  zone_id = module.vpc.aws_route53_environment_zone_id
  name    = "ssh.${var.context.environment.name}.${var.context.product.root_domain_name}"
  type    = "A"
  ttl     = 60

  records = [module.default-efs-instance.public_ip]
}

