variable "vpc_cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "dns_ip" {
  type    = "string"
  default = "10.0.0.2"
}

variable "environment_cidr" {
  type    = "string"
  default = "10.0.16.0/20"
}

variable "consul_leader_ip" {
  type    = "string"
  default = "10.0.0.4"
}

variable "consul_server_instance_ips" {
  default = {
    "0" = "10.0.0.5"
    "1" = "10.0.0.6"
    "2" = "10.0.0.7"
    "3" = "10.0.0.8"
    "4" = "10.0.0.9"
    "5" = "10.0.0.10"
    "6" = "10.0.0.11"
    "7" = "10.0.0.12"
    "8" = "10.0.0.13"
    "9" = "10.0.0.14"
  }
}

variable "concourse_ip" {
  type    = "string"
  default = "10.0.0.100"
}

variable "nexus_ip" {
  type    = "string"
  default = "10.0.0.132"
}

variable "dashing_ip" {
  type    = "string"
  default = "10.0.0.148"
}

/*
 *     ___  ___  ___ _   _ _ __(_) |_ _   _    __ _ _ __ ___  _   _ _ __  ___ 
 *    / __|/ _ \/ __| | | | '__| | __| | | |  / _` | '__/ _ \| | | | '_ \/ __|
 *    \__ \  __/ (__| |_| | |  | | |_| |_| | | (_| | | | (_) | |_| | |_) \__ \
 *    |___/\___|\___|\__,_|_|  |_|\__|\__, |  \__, |_|  \___/ \__,_| .__/|___/
 *                                    |___/   |___/                |_|        
 */

resource "aws_security_group" "ssh" {
  name = "ssh-${var.product}-${var.environment}"

  vpc_id     = "${var.aws_vpc_id}"
  depends_on = ["aws_vpc.default"]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.admin_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "ssh-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
  }
}
