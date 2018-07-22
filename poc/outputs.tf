output "dashing_task_count" {
   value = "${module.murray.dashing_task_count}"
}

output "nexus_task_count" {
   value = "${module.murray.nexus_task_count}"
}

output "concourse_task_count" {
   value = "${module.murray.concourse_task_count}"
}

output "monitoring_task_count" {
   value = "${module.murray.monitoring_task_count}"
}

output "postgres_db_address" {
   value = "${module.murray.postgres_db_address}"
}
