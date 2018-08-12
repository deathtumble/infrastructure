variable "globals" {
  type   = "map"
  default = {
    product="" 
    environment="" 
    root_domain_name="" 
    aws_route53_zone_id="" 
    admin_cidr=""
    nameTag=""
    key_name=""
  }
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

variable "gateway_id" {
  type = "string"
}

variable "aws_subnet_id" {
  type = "string"
}

variable "desired_instance_count" {
  type = "string"
  default = "1"
}

