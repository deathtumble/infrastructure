variable "role" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "elb" {
  type    = "string"
  default = true
}

variable "listener_arn" {
  type = "string"
}

variable "elb_instance_port" {}

variable "alb_priority" {
  type = "string"
}

variable "protocol" {
  type    = "string"
  default = "http"
}

variable "aws_alb_default_dns_name" {
  type = "string"
}

variable "aws_route53_zone_id" {
  type = "string"
}

variable "healthcheck_path" {}

variable "healthcheck_protocol" {}

variable "aws_instance_id" {}

variable "root_domain_name" {
  type = "string"
}

variable "subnets" {}

variable "product" {}

variable "environment" {}
