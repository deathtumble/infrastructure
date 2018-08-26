variable "docker_tag" {
  type = "string"
}

variable "aws_security_group_os_id" {
  type = "string"
}

variable "prometheus_access_id" {
  type = "string"
}

variable "prometheus_secret_access_key" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "availability_zone" {
  type = "string"
}

variable "task_status" {
  type = "string"
}

variable "ecs_ami_id" {
  type = "string"
}

variable "subnet_id" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "aws_alb_default_dns_name" {
  type = "string"
}

variable "aws_route53_environment_zone_id" {
  type = "string"
}

variable "aws_lb_listener_default_arn" {
  type = "string"
}

variable "globals" {
  type = "map"

  default = {
    product              = ""
    environment          = ""
    root_domain_name     = ""
    admin_cidr           = ""
    nameTag              = ""
    nexus_volume_id      = ""
    monitoring_volume_id = ""
    key_name             = ""
  }
}

