variable "role" {}

variable "elb" {
  type    = "string"
  default = true
}

variable "elb_security_group" {}

variable "elb_instance_port" {}

variable "elb_port" {}

variable "protocol" {
    type = "string"
    default = "http"
}

variable "healthcheck_path" {}

variable "healthcheck_protocol" {}

variable "healthcheck_port" {}

variable "aws_route53_record_zone_id" {}

variable "aws_instance_id" {}

variable "subnets" {}

variable "product" {}

variable "environment" {}
