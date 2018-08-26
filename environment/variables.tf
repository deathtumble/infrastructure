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

variable "concourse_docker_tag" {
  type    = "string"
  default = "2395dbb"
}

variable "prometheus_docker_tag" {
  type    = "string"
  default = "8a983d4"
}
