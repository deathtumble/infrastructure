provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "default" {
	cidr_block = "${var.ecosystem_cidr}"
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
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
  
  depends_on = ["aws_vpc.default"]
}

resource "aws_network_acl" "default" {
  vpc_id = "${aws_vpc.default.id}"

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

  depends_on = ["aws_vpc.default"]
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.default.id}"

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

  depends_on = ["aws_vpc.default"]
}

resource "aws_main_route_table_association" "default" {
  vpc_id         = "${aws_vpc.default.id}"
  route_table_id = "${aws_route_table.main.id}"
  depends_on = ["aws_vpc.default", "aws_route_table.main"]
}

resource "aws_route53_zone" "root" {
  name = "${var.root_domain_name}."
}




