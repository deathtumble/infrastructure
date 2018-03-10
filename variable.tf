variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "availability_zone" {
  type    = "string"
  default = "eu-west-1c"
}

variable "aws_vpc_id" {
  type    = "string"
}

variable "root_domain_name" {
  type    = "string"
  default = "urbanfortress.uk"
}

variable "product" {
  type    = "string"
  default = "poc"
}

variable "environment" {
  type    = "string"
  default = "poc"
}

variable "nameTag" {
  type    = "string"
  default = "poc-poc"
}

variable "admin_cidr" {
  type    = "string"
  default = "81.174.166.51/32"
}

variable "vpc_cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "dns_ip" {
  type    = "string"
  default = "10.0.0.2"
}

variable "environment_cidr" {
  type    = "string"
  default = "10.0.16.0/20"
}

variable "weblayer_cidr" {
  type    = "string"
  default = "10.0.16.0/23"
}

variable "consul_subnet" {
  type    = "string"
  default = "10.0.0.0/27"
}

variable "monitoring_subnet" {
  type    = "string"
  default = "10.0.0.32/27"
}

variable "chatops_subnet" {
  type    = "string"
  default = "10.0.0.64/27"
}

variable "concourse_subnet" {
  type    = "string"
  default = "10.0.0.96/27"
}

variable "nexus_subnet" {
  type    = "string"
  default = "10.0.0.128/28"
}

variable "dashing_subnet" {
  type    = "string"
  default = "10.0.0.144/28"
}

variable "consul_leader_ip" {
  type    = "string"
  default = "10.0.0.4"
}

variable "consul_server_instance_ips" {
  default = {
    "0" = "10.0.0.5"
    "1" = "10.0.0.6"
    "2" = "10.0.0.7"
    "3" = "10.0.0.8"
    "4" = "10.0.0.9"
    "5" = "10.0.0.10"
    "6" = "10.0.0.11"
    "7" = "10.0.0.12"
    "8" = "10.0.0.13"
    "9" = "10.0.0.14"
  }
}

variable "consul_server_count" {
  type    = "string"
  default = "2"
}

variable "concourse_ip" {
  type    = "string"
  default = "10.0.0.100"
}

variable "nexus_ip" {
  type    = "string"
  default = "10.0.0.132"
}

variable "dashing_ip" {
  type    = "string"
  default = "10.0.0.148"
}

variable "ecs_ami_id" {
  type    = "string"
  default = "ami-eac98593"
}
