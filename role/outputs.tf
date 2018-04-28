output "instance_id" {
  value = "${aws_instance.this.id}"
}

output "aws_alb_target_group_arn" {
  value = "${aws_alb_target_group.this.arn}"
}