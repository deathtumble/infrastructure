variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "availability_zone" {
  type    = "string"
  default = "eu-west-1c"
}

variable "ecs_ami_id" {
  type    = "string"
  default = "ami-eac98593"
}

variable "aws_route53_zone_id" {
  type = "string"
}

variable "nexus_volume_id" {
  type = "string"
}

variable "monitoring_volume_id" {
  type = "string"
}

variable "concourse_volume_id" {
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
