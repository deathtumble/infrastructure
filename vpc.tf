provider "aws" {
  region     = "${var.region}"
}

data "aws_vpc" "selected" {
 filter {
    name   = "tag:Name"
    values = ["${var.nameTag}"]
  }
}

resource "aws_vpc" "default" {
	cidr_block = "10.0.0.0/28"
	instance_tenancy = "default"
	enable_dns_support = true
	enable_dns_hostnames = true
	enable_classiclink = false
	assign_generated_ipv6_cidr_block = false
  tags {
    Name = "${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_network_acl" "default" {
  vpc_id = "${data.aws_vpc.selected.id}"

  egress {
    protocol = "-1"
    rule_no = "100"
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = "0"
    to_port = "0"
  }
    		
  ingress {
    protocol = "-1"
    rule_no = "100"
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = "0"
    to_port = "0"
  }

  tags {
    Name = "${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "main-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }

  tags {
    Name = "${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_main_route_table_association" "default" {
  vpc_id         = "${data.aws_vpc.selected.id}"
  route_table_id = "${aws_route_table.main.id}"
}
