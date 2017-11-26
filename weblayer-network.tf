data "aws_subnet" "weblayer" {
 filter {
    name   = "tag:Name"
    values = ["weblayer-${var.nameTag}"]
  }
}

data "aws_route_table" "weblayer" {
 filter {
    name   = "tag:Name"
    values = ["weblayer-${var.nameTag}"]
  }
}

data "aws_security_group" "weblayer" {
 filter {
    name   = "tag:Name"
    values = ["weblayer-${var.nameTag}"]
  }
}

resource "aws_route_table" "weblayer" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "weblayer-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "weblayer"
  }
}

resource "aws_route" "weblayer" {
  route_table_id = "${data.aws_route_table.weblayer.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table_association" "default" {
  subnet_id      = "${data.aws_subnet.weblayer.id}"
  route_table_id = "${data.aws_route_table.weblayer.id}"
}


resource "aws_security_group" "weblayer" {
  name        = "weblayer"
  
  description = "weblayer security group"
  vpc_id = "${data.aws_vpc.selected.id}"

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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_subnet" "weblayer" {
  vpc_id     = "${data.aws_vpc.selected.id}"
  cidr_block = "10.0.0.0/27"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "weblayer-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "weblayer"
  }
}

