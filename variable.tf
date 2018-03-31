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

variable "ecs_ami_id" {
  type    = "string"
  default = "ami-8ba0eaf2"
}

variable "concourse_desired_count" {
  type    = "string"
  default = "1"
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
