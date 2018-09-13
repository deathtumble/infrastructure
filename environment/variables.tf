variable "vpc_cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "dns_ip" {
  type    = "string"
  default = "10.0.0.2"
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

variable "elasticsearch_task_status" {
  type    = "string"
  default = "up"
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

variable "aws_proxy_task_status" {
  type    = "string"
  default = "up"
}

variable "grafana_task_status" {
  type    = "string"
  default = "up"
}

variable "prometheus_task_status" {
  type    = "string"
  default = "up"
}

variable "consul_task_status" {
  type    = "string"
  default = "up"
}

variable "globals" {
  type = "map"
}

variable "secrets" {
  type = "map"
}

variable "ecs_ami_id" {
  type    = "string"
  default = "ami-0646e0dc7c3aac6a6"
}

variable "aws_proxy_docker_tag" {
  type    = "string"
  default = "1b2184b"
}

variable "dashing_docker_tag" {
  type    = "string"
  default = "313380c"
}

variable "consul_docker_tag" {
  type    = "string"
  default = "139d617"
}

variable "grafana_docker_tag" {
  type    = "string"
  default = "5.1.0"
}


variable "concourse_docker_tag" {
  type    = "string"
  default = "2395dbb"
}

variable "nexus_docker_tag" {
  type    = "string"
  default = "3.10.0"
}

variable "prometheus_docker_tag" {
  type    = "string"
  default = "2b1e455"
}
