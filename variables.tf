variable "consul_server_count" {
  type    = "string"
  default = "2"
}

variable "consul_server_instance_names" {
  default = {
    "0" = "1"
    "1" = "2"
    "2" = "3"
  }
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
  default = "26fe3cc"
}

variable "collectd_docker_tag" {
  type    = "string"
  default = "0.1.1"
}

variable "concourse_docker_tag" {
  type    = "string"
  default = "fb947a1"
}

variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "availability_zone_1" {
  type    = "string"
  default = "eu-west-1c"
}

variable "availability_zone_2" {
  type    = "string"
  default = "eu-west-1b"
}

variable "ecs_ami_id" {
  type    = "string"
  default = "ami-1f4749f5"
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

variable "aws_route53_zone_id" {
  type = "string"
}

variable "nexus_volume_id" {
  type = "string"
}

variable "monitoring_volume_id" {
  type = "string"
}

variable "concourse_volume_id" {
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
