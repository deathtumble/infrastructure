variable "role" {
}

variable "ami_id" {
    default = "ami-567b1a2f"
}

variable "availability_zone" {
}

variable "private_ip" {
}

variable "instance_type" {
    default = "t2.small"
}

variable "ecosystem" {
}

variable "environment" {
}

variable "volume_id" {
}

variable "cidr_block" {
}

variable "vpc_id" {
}

variable "vpc_security_group_ids" {
    type    = "list"
}

variable "gateway_id" {
}

variable "elb_security_group" {
}

variable "elb_instance_port" {
}

variable "elb_port" {
}

variable "healthcheck_path" {
}

variable "healthcheck_protocol" {
}

variable "healthcheck_port" {
}

variable "aws_route53_record_zone_id" {
}

variable "task_definition" {
}

variable "desired_count" {
}