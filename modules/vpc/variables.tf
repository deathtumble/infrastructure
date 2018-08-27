variable "vpc_cidr" {
  type    = "string"
}

variable "dns_ip" {
  type    = "string"
}

variable "aws_security_group_alb_id" {
  type    = "string"
}

variable "environment_cidr" {
  type    = "string"
  default = "10.0.16.0/20"
}

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

variable "globals" {
  type = "map"
}