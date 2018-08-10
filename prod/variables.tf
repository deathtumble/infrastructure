variable "region" {
  type    = "string"
  default = "eu-west-1"
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

variable "globals" {
  type   = "map"
  default = {
    product="" 
    environment="" 
    root_domain_name="" 
    aws_route53_zone_id="" 
    admin_cidr=""
    nameTag=""
    nexus_volume_id=""
    monitoring_volume_id="" 
    key_name=""
  }
}
