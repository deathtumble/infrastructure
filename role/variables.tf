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

variable "aws_subnet_id" {
} 

variable "ecosystem" {
}

variable "environment" {
}

variable "volume_id" {
}

variable "vpc_security_group_ids" {
    type    = "list"
}