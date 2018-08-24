output "dashing_task_count" {
  value = "${module.prod.dashing_task_count}"
}

output "nexus_task_count" {
  value = "${module.prod.nexus_task_count}"
}

output "concourse_task_count" {
  value = "${module.prod.concourse_task_count}"
}

output "monitoring_task_count" {
  value = "${module.prod.monitoring_task_count}"
}

output "consul_task_count" {
  value = "${module.prod.consul_task_count}"
}

output "aws_alb_default_dns_name" {
  value = "${module.prod.aws_alb_default_dns_name}"
}
