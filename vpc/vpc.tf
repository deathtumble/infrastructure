provider "aws" {
  region     = "eu-west-1"
}

data "aws_vpc" "selected" {
 filter {
    name   = "tag:Name"
    values = ["${var.nameTag}"]
  }
}

data "aws_route_table" "selected" {
 filter {
    name   = "tag:Name"
    values = ["${var.nameTag}"]
  }
}

data "aws_subnet" "selected" {
 filter {
    name   = "tag:Name"
    values = ["${var.nameTag}"]
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

resource "aws_subnet" "default" {
  vpc_id     = "${data.aws_vpc.selected.id}"
  cidr_block = "10.0.0.0/28"

  tags {
    Name = "${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_security_group" "helloworld" {
  name        = "helloworld"
  
  description = "helloworld Security Group"
  vpc_id = "${data.aws_vpc.selected.id}"

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
    Name = "${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_route" "default" {
  route_table_id               = "${data.aws_route_table.selected.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table" "default" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "default" {
  subnet_id      = "${data.aws_subnet.selected.id}"
  route_table_id = "${data.aws_route_table.selected.id}"
}

resource "aws_main_route_table_association" "default" {
  vpc_id         = "${data.aws_vpc.selected.id}"
  route_table_id = "${data.aws_route_table.selected.id}"
}

// resource "aws_vpc_dhcp_options" "foo" {
//   domain_name          = "service.consul"
//   domain_name_servers  = ["127.0.0.1", "10.0.0.2"]
//   ntp_servers          = ["127.0.0.1"]
//   netbios_name_servers = ["127.0.0.1"]
//   netbios_node_type    = 2
//
//   tags {
//     Name = "${var.nameTag}"
//     Ecosystem = "${var.ecosystem}"
//     Environment = "${var.environment}"
//   }
// }