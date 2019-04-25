variable "aws_security_group_alb_id" {
  type = string
}

variable "vpc_name" {
  type = string
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



