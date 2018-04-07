variable "role" {
  type = "string"
}

variable "ami_id" {
  type = "string"
}

variable "availability_zone" {
  type = "string"
}

variable "instance_type" {
  default = "t2.small"
}

variable "product" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "volume_id" {
  default = ""
}

variable "elb_protocol" {
  type    = "string"
  default = "http"
}

variable "vpc_id" {
  type = "string"
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "listener_arn" {
  type = "string"
}

variable "aws_alb_default_dns_name" {
  type = "string"
}

variable "aws_route53_zone_id" {
  type = "string"
}

variable "gateway_id" {
  type = "string"
}

variable "alb_priority" {
  type = "string"
}

variable "root_domain_name" {
  type = "string"
}

variable "elb_instance_port" {
  type = "string"
}

variable "healthcheck_path" {
  type = "string"
}

variable "healthcheck_protocol" {
  type = "string"
}

variable "aws_subnet_id" {
  type = "string"
}

variable "task_definition" {
  type = "string"
}

variable "desired_count" {
  type = "string"
}

variable "key_name" {
  type = "string"
}
