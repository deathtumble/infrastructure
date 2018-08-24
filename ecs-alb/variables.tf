variable "root_domain_name" {
  type = "string"
}

variable "product" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "aws_route53_environment_zone_id" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "task_definition" {
  type = "string"
}

variable "task_status" {
  type = "string"
}

variable "desired_task_count" {
  type    = "string"
  default = "1"
}

variable "role" {
  type = "string"
}

variable "elb_instance_port" {
  type = "string"
}

variable "aws_lb_listener_default_arn" {
  type = "string"
}

variable "aws_lb_listener_rule_priority" {
  type = "string"
}

variable "healthcheck_path" {
  type = "string"
}

variable "aws_alb_default_dns_name" {
  type = "string"
}

variable "healthcheck_protocol" {
  type = "string"
}

variable "elb_protocol" {
  type    = "string"
  default = "http"
}

/*variable "globals" {
  type   = "map"
  default = {
    product="" 
    environment="" 
    root_domain_name="" 
    admin_cidr=""
    nameTag=""
    key_name=""
  }
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

variable "volume_id" {
  default = ""
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

*/

