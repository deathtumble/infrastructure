data "aws_subnet" "zookeeper" {
 filter {
    name   = "tag:Name"
    values = ["zookeeper-${var.nameTag}"]
  }
}

data "aws_route_table" "zookeeper" {
 filter {
    name   = "tag:Name"
    values = ["zookeeper-${var.nameTag}"]
  }
}

data "aws_security_group" "zookeeper" {
 filter {
    name   = "tag:Name"
    values = ["zookeeper-${var.nameTag}"]
  }
}

resource "aws_route_table" "zookeeper" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "zookeeper-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "zookeeper"
  }
}

resource "aws_route" "zookeeper" {
  route_table_id = "${data.aws_route_table.zookeeper.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table_association" "zookeeper" {
  subnet_id      = "${data.aws_subnet.zookeeper.id}"
  route_table_id = "${data.aws_route_table.zookeeper.id}"
}


resource "aws_security_group" "zookeeper" {
  name        = "zookeeper"
  
  description = "zookeeper Security Group"
  vpc_id = "${data.aws_vpc.selected.id}"

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "10.0.0.0/16"]
  }

  ingress {
    from_port   = 8181
    to_port     = 8181
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "10.0.0.0/16"]
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "10.0.0.0/16"]
  }

  ingress {
    from_port   = 2888
    to_port     = 2888
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "10.0.0.0/16"]
  }

  ingress {
    from_port   = 3888
    to_port     = 3888
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "10.0.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "10.0.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "zookeeper-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "zookeeper"
  }
}

resource "aws_subnet" "zookeeper" {
  vpc_id     = "${data.aws_vpc.selected.id}"
  cidr_block = "10.0.0.64/28"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "zookeeper-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "zookeeper"
  }
}
