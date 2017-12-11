variable "consul_cidr" {
	type = "string"
	default = "10.0.0.0/16"
}

variable "consul_server_instance_ips" {
  default = {
    "0" = "10.0.0.69"
    "1" = "10.0.0.70"
    "2" = "10.0.0.71"
  }
}

variable "consul_server_instance_names" {
  default = {
    "0" = "1"
    "1" = "2"
    "2" = "3"
  }
}

resource "aws_route_table" "consul" {
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name = "consul-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "consul"
  }
}

resource "aws_route" "consul" {
  route_table_id = "${aws_route_table.consul.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
  depends_on = ["aws_route_table.consul", "aws_internet_gateway.default"]
}

resource "aws_subnet" "consul" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.64/27"
  availability_zone = "${var.availability_zone}"
  depends_on      = ["aws_vpc.default", "aws_route_table.consul"]

  tags {
    Name = "consul-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "consul"
  }
}

resource "aws_route_table_association" "consul" {
  subnet_id      = "${aws_subnet.consul.id}"
  route_table_id = "${aws_route_table.consul.id}"
  depends_on = ["aws_route_table.consul", "aws_subnet.consul"]
}

resource "aws_security_group" "consul" {
  name        = "consul"
  
  description = "consul security group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }
  
  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 2003
    to_port     = 2003
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "udp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "consul-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "consul"
  }
}


