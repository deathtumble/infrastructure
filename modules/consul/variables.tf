variable "docker_tag" {
  type = string
}

variable "task_status" {
  type = string
}

variable "dns_ip" {
  type = string
}

variable "vpc" {
  type = map(string)
}

variable "az" {
  type = map(string)
}

variable "globals" {
  type = map(string)

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

