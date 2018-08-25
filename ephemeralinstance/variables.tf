variable "globals" {
  type = "map"

  default = {
    product     = ""
    environment = ""
    admin_cidr  = ""
    nameTag     = ""
    key_name    = ""
  }
}

variable "count" {
  type = "string"
  default = "1" 
}

variable "cluster_name" {
  type = "string" 
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
