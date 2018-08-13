output "dashing_task_count" {
   value = "${module.environment.dashing_task_count}"
}

output "nexus_task_count" {
   value = "${module.environment.nexus_task_count}"
}

output "concourse_task_count" {
   value = "${module.environment.concourse_task_count}"
}

output "monitoring_task_count" {
   value = "${module.environment.monitoring_task_count}"
}

output "consul_task_count" {
   value = "${module.environment.consul_task_count}"
}
