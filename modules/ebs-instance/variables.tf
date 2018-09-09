variable "globals" {
  type = "map"

}

variable "cluster_name" {
  type = "string" 
}

variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "ami_id" {
  type = "string"
}

variable "availability_zone" {
  type = "string"
}

variable "subnet_id" {
  type = "string"
}

variable "instance_type" {
  default = "t2.small"
}

variable "efs_id" {
}

variable "vpc_id" {
  type = "string"
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "desired_instance_count" {
  type    = "string"
  default = "1"
}
