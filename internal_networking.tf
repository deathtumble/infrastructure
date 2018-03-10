resource "aws_route_table" "consul" {
  vpc_id     = "${var.aws_vpc_id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name        = "consul-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer       = "consul"
  }
}

resource "aws_route" "consul" {
  route_table_id         = "${aws_route_table.consul.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"

  depends_on = ["aws_route_table.consul", "aws_internet_gateway.default"]
}

resource "aws_subnet" "consul" {
  vpc_id            = "${var.aws_vpc_id}"
  cidr_block        = "${var.consul_subnet}"
  availability_zone = "${var.availability_zone}"
  depends_on        = ["aws_vpc.default", "aws_route_table.consul"]

  tags {
    Name    = "consul-${var.nameTag}"
    Service = "consul"
  }
}

resource "aws_route_table_association" "consul" {
  subnet_id      = "${aws_subnet.consul.id}"
  route_table_id = "${aws_route_table.consul.id}"
  depends_on     = ["aws_route_table.consul", "aws_subnet.consul"]
}

resource "aws_route_table" "weblayer" {
  vpc_id     = "${var.aws_vpc_id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name        = "weblayer-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer       = "weblayer"
  }
}

resource "aws_route" "weblayer" {
  route_table_id         = "${aws_route_table.weblayer.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
  depends_on             = ["aws_route_table.weblayer", "aws_internet_gateway.default"]
}

resource "aws_subnet" "weblayer" {
  vpc_id            = "${var.aws_vpc_id}"
  cidr_block        = "${var.weblayer_cidr}"
  availability_zone = "${var.availability_zone}"
  depends_on        = ["aws_subnet.weblayer", "aws_route_table.weblayer"]

  tags {
    Name        = "weblayer-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer       = "weblayer"
  }
}

resource "aws_route_table_association" "weblayer" {
  subnet_id      = "${aws_subnet.weblayer.id}"
  route_table_id = "${aws_route_table.weblayer.id}"
  depends_on     = ["aws_subnet.weblayer", "aws_route_table.weblayer"]
}

/*
 *     ___  ___  ___ _   _ _ __(_) |_ _   _    __ _ _ __ ___  _   _ _ __  ___ 
 *    / __|/ _ \/ __| | | | '__| | __| | | |  / _` | '__/ _ \| | | | '_ \/ __|
 *    \__ \  __/ (__| |_| | |  | | |_| |_| | | (_| | | | (_) | |_| | |_) \__ \
 *    |___/\___|\___|\__,_|_|  |_|\__|\__, |  \__, |_|  \___/ \__,_| .__/|___/
 *                                    |___/   |___/                |_|        
 */

resource "aws_security_group" "consului" {
  name = "consului"

  description = "consului security group"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.admin_cidrs}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "consului-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer       = "consul"
  }
}

resource "aws_security_group" "ssh" {
  name = "ssh-${var.nameTag}"

  vpc_id     = "${var.aws_vpc_id}"
  depends_on = ["aws_vpc.default"]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}", "${var.admin_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "ssh-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "consul-server" {
  name = "consul-server-${var.nameTag}"

  vpc_id     = "${var.aws_vpc_id}"
  depends_on = ["aws_vpc.default"]

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}", "${var.admin_cidr}"]
  }

  tags {
    Name        = "consul-server-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "consul-client" {
  name = "consul-client-${var.nameTag}"

  vpc_id     = "${var.aws_vpc_id}"
  depends_on = ["aws_vpc.default"]

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  tags {
    Name        = "consul-client-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "weblayer" {
  name = "weblayer-${var.nameTag}"

  vpc_id     = "${var.aws_vpc_id}"
  depends_on = ["aws_vpc.default"]

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}", "${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}", "${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8181
    to_port     = 8181
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}", "${var.admin_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "weblayer-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
  }
}
