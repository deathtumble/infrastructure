output "dashing_task_count" {
  value = "${module.environment.dashing_task_count}"
}

output "nexus_task_count" {
  value = "${module.environment.nexus_task_count}"
}

output "concourse_task_count" {
  value = "${module.environment.concourse_task_count}"
}

output "grafana_task_count" {
  value = "${module.environment.grafana_task_count}"
}

output "consul_task_count" {
  value = "${module.environment.consul_task_count}"
}

output "aws_alb_default_dns_name" {
  value = "${module.environment.aws_alb_default_dns_name}"
}
