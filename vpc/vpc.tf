provider "aws" {
  region     = "eu-west-1"
}

resource "aws_vpc" "poc" {
	cidr_block = "10.0.0.0/28"
	instance_tenancy = ""
	enable_dns_support = ""
	enable_dns_hostnames = ""
}

resource "aws_security_group" "helloworld" {
  name        = "helloworld"
  
  description = "helloworld Security Group"
  vpc_id = "vpc-71d5e815"

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["81.174.166.51/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["81.174.166.51/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["81.174.166.51/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
	tags {
		Name = "nexus"
	}

}

