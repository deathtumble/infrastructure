variable "docker_tag" {
  type = "string"
}

variable "task_status" {
  type = "string"
}

variable "aws_subnet_av1_id" {
  type = "string"
}

variable "aws_subnet_av2_id" {
  type = "string"
}

variable "concourse_password" {
  type = "string"
}

variable "concourse_postgres_password" {
  type = "string"
}

variable "vpc" {
  type = "map"
}

variable "az" {
  type = "map"
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

