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

variable "product" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "volume_id" {
  default = ""
}

variable "vpc_id" {
  type = "string"
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "root_domain_name" {
  type = "string"
}

variable "aws_subnet_id" {
  type = "string"
}

variable "desired_task_count" {
  type = "string"
  default = "1"
}

variable "desired_instance_count" {
  type = "string"
  default = "1"
}

variable "key_name" {
  type = "string"
}
