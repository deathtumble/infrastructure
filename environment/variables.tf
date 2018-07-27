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
  default = "ami-2d6a8fc0"
}

variable "aws_proxy_docker_tag" {
  type    = "string"
  default = "b6bf5ff"
}

variable "dashing_docker_tag" {
  type    = "string"
  default = "cac2f6b"
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

variable "concourse_postgres_password" {
  type    = "string"
}

variable "concourse_password" {
  type    = "string"
}

variable "aws-proxy_access_id" {
  type    = "string"
}

variable "aws-proxy_secret_access_key" {
  type    = "string"
}

variable "concourse_tsa_host_key_value" {
  type = "string"
}

variable "concourse_tsa_authorized_keys_value" {
  type = "string"
}

variable "concourse_session_signing_key_value" {
  type = "string"
}

variable "concourse_tsa_public_key_value" {
  type = "string"
}

variable "concourse_tsa_worker_private_key_value" {
  type = "string"
}




