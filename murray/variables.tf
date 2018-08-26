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

variable "grafana_task_status" {
  type    = "string"
  default = "up"
}

variable "consul_task_status" {
  type    = "string"
  default = "up"
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
    grafana_volume_id    = ""
    key_name             = ""
    "ecs_iam_role"       = ""
  }
}
