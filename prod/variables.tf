variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "aws_route53_zone_id" {
  type = "string"
}

variable "nexus_volume_id" {
  type = "string"
}

variable "monitoring_volume_id" {
  type = "string"
}

variable "key_name" {
  type = "string"
}

variable "root_domain_name" {
  type = "string"
}

variable "product" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "nameTag" {
  type = "string"
}

variable "admin_cidr" {
  type = "string"
}

variable "ecs_ami_id" {
  type    = "string"
  default = "ami-1f4749f5"
}

variable "aws_proxy_docker_tag" {
  type    = "string"
  default = "2959b2e"
}

variable "dashing_docker_tag" {
  type    = "string"
  default = "6151710"
}

variable "consul_docker_tag" {
  type    = "string"
  default = "139d617"
}

variable "concourse_docker_tag" {
  type    = "string"
  default = "88e46cc"
}

variable "collectd_docker_tag" {
  type    = "string"
  default = "0.1.1"
}

variable "concourse_task_status" {
  type    = "string"
  default = "up"
}

variable "nexus_task_status" {
  type    = "string"
  default = "up"
}

variable "dashing_task_status" {
  type    = "string"
  default = "up"
}

variable "monitoring_task_status" {
  type    = "string"
  default = "up"
}

