variable "cluster_name" {
  type = string
}

variable "root_domain_name" {
  type = string
}

variable "product" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_route53_environment_zone_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "task_definition" {
  type = string
}

variable "task_status" {
  type = string
}

variable "desired_task_count" {
  type    = string
  default = "1"
}

variable "role" {
  type = string
}

variable "elb_instance_port" {
  type = string
}

variable "aws_lb_listener_default_arn" {
  type = string
}

variable "aws_lb_listener_rule_priority" {
  type = string
}

variable "healthcheck_path" {
  type = string
}

variable "aws_alb_default_dns_name" {
  type = string
}

variable "healthcheck_protocol" {
  type = string
}

variable "elb_protocol" {
  type    = string
  default = "http"
}

variable "ecs_iam_role" {		
  type = string
}

variable "healthchecks" {
  type = map(any)
}

