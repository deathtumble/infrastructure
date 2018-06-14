output "dashing_task_count" {
   value = "${module.dashing.task_count}"
}

output "nexus_task_count" {
   value = "${module.nexus.task_count}"
}

output "concourse_task_count" {
   value = "${module.concourse.task_count}"
}

output "monitoring_task_count" {
   value = "${module.monitoring.task_count}"
}

output "postgres_db_address" {
   value = "${aws_db_instance.concourse.address}"
}
