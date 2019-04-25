variable "instance_count" {
  type    = string
  default = "1"
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "ami_id" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  default = "t2.small"
}

variable "efs_id" {
}

variable "vpc_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "desired_instance_count" {
  type    = string
  default = "1"
}

variable "context" {
  type = object({
    aws_account_id = string
    region = object({
      name   = string
      efs_id = string
    })
    environment = object({
      name     = string
      key_name = string
    })
    product = object({
      name             = string
      root_domain_name = string
    })
    vpcs = map(object({
      name   = string
      cidr   = string
      dns_ip = string
      azs = map(object({
        name   = string
        subnet = string
      }))
    }))
  })
}


