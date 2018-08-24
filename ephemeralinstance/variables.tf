variable "globals" {
  type   = "map"
  default = {
    product="" 
    environment="" 
    admin_cidr=""
    nameTag=""
    key_name=""
  }
}

variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "role" {
  type = "string"
}

variable "ami_id" {
  type = "string"
}

variable "availability_zone" {
  type = "string"
}

variable "instance_type" {
  default = "t2.small"
}

variable "vpc_id" {
  type = "string"
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "aws_subnet_id" {
  type = "string"
}

variable "desired_instance_count" {
  type = "string"
  default = "1"
}

