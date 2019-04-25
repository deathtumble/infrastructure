variable "elasticsearch_docker_tag" {
  type    = string
  default = "e7499ed"
}

variable "logstash_docker_tag" {
  type    = string
  default = "2cd0b80"
}

variable "concourse_task_status" {
  type    = string
  default = "up"
}

variable "nexus_task_status" {
  type    = string
  default = "up"
}

variable "dashing_task_status" {
  type    = string
  default = "up"
}

variable "grafana_task_status" {
  type    = string
  default = "up"
}

variable "consul_task_status" {
  type    = string
  default = "up"
}

variable "prometheus_task_status" {
  type    = string
  default = "up"
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

variable "services" {
  type = map(object({
    name          = string
    desired_count = string
    docker_tag    = string
    task_status   = string
  }))
}

