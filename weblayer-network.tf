resource "aws_route_table" "weblayer" {
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name = "weblayer-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "weblayer"
  }
}

resource "aws_route" "weblayer" {
  route_table_id = "${aws_route_table.weblayer.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
  depends_on = ["aws_route_table.weblayer", "aws_internet_gateway.default"]
}

resource "aws_subnet" "weblayer" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/27"
  availability_zone = "${var.availability_zone}"
  depends_on      = ["aws_subnet.weblayer", "aws_route_table.weblayer"]

  tags {
    Name = "weblayer-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "weblayer"
  }
}

resource "aws_route_table_association" "weblayer" {
  subnet_id      = "${aws_subnet.weblayer.id}"
  route_table_id = "${aws_route_table.weblayer.id}"
  depends_on = ["aws_subnet.weblayer", "aws_route_table.weblayer"]
}

resource "aws_security_group" "weblayer" {
  name        = "weblayer"
  
  description = "weblayer security group"
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.consul_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8181
    to_port     = 8181
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
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
    Name = "weblayer-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "weblayer"
  }
}


