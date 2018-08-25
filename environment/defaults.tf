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

variable "server_instance_names" {
  default = {
    "0" = "0"
    "1" = "1"
    "2" = "2"
    "3" = "3"
    "4" = "4"
    "5" = "5"
  }
}

