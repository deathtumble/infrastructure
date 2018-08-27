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

variable "secrets" {
  type = "map"

  default = {
    concourse_postgres_password            = ""
    rundeck_maria_password                 = ""
    concourse_password                     = ""
    concourse_access_key_id                = ""
    concourse_secret_access_key            = ""
    aws-proxy_access_id                    = ""
    aws-proxy_secret_access_key            = ""
    concourse_tsa_authorized_keys_value    = ""
    concourse_tsa_public_key_value         = ""
    concourse_tsa_host_key_value           = ""
    concourse_session_signing_key_value    = ""
    concourse_tsa_worker_private_key_value = ""
  }
}

variable "ecs_ami_id" {
  type    = "string"
  default = "ami-069fc5ce535f1da38"
}

variable "aws_proxy_docker_tag" {
  type    = "string"
  default = "c881c50"
}

variable "dashing_docker_tag" {
  type    = "string"
  default = "3f32444"
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
  default = "8a983d4"
}
