variable "role" {}

variable "ami_id" {
  default = "ami-567b1a2f"
}

variable "availability_zone" {}

variable "private_ip" {
  default = ""
}

variable "instance_type" {
  default = "t2.small"
}

variable "product" {}

variable "environment" {}

variable "volume_id" {
  default = ""
}

variable "elb_protocol" {
  type    = "string"
  default = "http"
}

variable "vpc_id" {}

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

variable "gateway_id" {}

variable "alb_priority" {
  type = "string"
}

variable "root_domain_name" {
  type = "string"
}

variable "elb_instance_port" {}

variable "healthcheck_path" {}

variable "healthcheck_protocol" {}

variable "aws_subnet_id" {}

variable "task_definition" {}

variable "desired_count" {}

variable "key_name" {
  type = "string"
}
