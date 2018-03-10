provider "aws" {
  region = "${var.region}"
}

provider "template" {
  version = "~> 0.1"
}

resource "aws_vpc" "default" {
  cidr_block                       = "${var.vpc_cidr}"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  assign_generated_ipv6_cidr_block = false

  tags {
    Name        = "${var.product}-${var.environment}"
    Product   = "${var.product}"
    Environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${var.aws_vpc_id}"

  tags {
    Name        = "${var.product}-${var.environment}"
    Product   = "${var.product}"
    Environment = "${var.environment}"
  }

  depends_on = ["aws_vpc.default"]
}

resource "aws_network_acl" "default" {
  vpc_id = "${var.aws_vpc_id}"

  egress {
    protocol   = "-1"
    rule_no    = "100"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    to_port    = "0"
  }

  ingress {
    protocol   = "-1"
    rule_no    = "100"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    to_port    = "0"
  }

  tags {
    Name        = "${var.product}-${var.environment}"
    Product   = "${var.product}"
    Environment = "${var.environment}"
  }

  depends_on = ["aws_vpc.default"]
}

resource "aws_route_table" "main" {
  vpc_id = "${var.aws_vpc_id}"

  tags {
    Name        = "main-${var.product}-${var.environment}"
    Product   = "${var.product}"
    Environment = "${var.environment}"
  }

  tags {
    Name        = "${var.product}-${var.environment}"
    Product   = "${var.product}"
    Environment = "${var.environment}"
  }

  depends_on = ["aws_vpc.default"]
}

resource "aws_main_route_table_association" "default" {
  vpc_id         = "${var.aws_vpc_id}"
  route_table_id = "${aws_route_table.main.id}"
  depends_on     = ["aws_vpc.default", "aws_route_table.main"]
}
