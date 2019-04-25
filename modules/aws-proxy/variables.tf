variable "docker_tag" {
  type = string
}

variable "task_status" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ecs_iam_role" {
  type = "string"
}

variable "aws_route53_environment_zone_id" {
  type = "string"
}

variable "aws_lb_listener_default_arn" {
  type = "string"
}

variable "aws_alb_default_dns_name" {
  type = "string"
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