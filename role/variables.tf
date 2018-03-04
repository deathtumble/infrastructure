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

variable "aws_security_group_id" {
}

variable "ecosystem" {
}

variable "environment" {
}

variable "aws_security_group_ssh_id" {
}

variable "aws_security_group_consul-client_id" {
}

variable "volume_id" {
}
