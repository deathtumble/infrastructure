output "task_count" {
  value = aws_ecs_service.this.desired_count
}

