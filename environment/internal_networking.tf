data "aws_route53_zone" "selected" {
  name = "${local.root_domain_name}."
}

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

/*
 *     ___  ___  ___ _   _ _ __(_) |_ _   _    __ _ _ __ ___  _   _ _ __  ___ 
 *    / __|/ _ \/ __| | | | '__| | __| | | |  / _` | '__/ _ \| | | | '_ \/ __|
 *    \__ \  __/ (__| |_| | |  | | |_| |_| | | (_| | | | (_) | |_| | |_) \__ \
 *    |___/\___|\___|\__,_|_|  |_|\__|\__, |  \__, |_|  \___/ \__,_| .__/|___/
 *                                    |___/   |___/                |_|        
 */

resource "aws_security_group" "os" {
  name = "os-${local.product}-${local.environment}"

  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${local.admin_cidr}"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${local.admin_cidr}", "${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "os-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
  }
  
  lifecycle {
    create_before_destroy = true
  }  
}


