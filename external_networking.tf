resource "aws_subnet" "av1" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "10.0.0.0/25"
  availability_zone = "${var.availability_zone_1}"

  tags {
    Name = "chatops-${var.product}-${var.environment}"
  }
}

resource "aws_subnet" "av2" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "10.0.0.128/25"
  availability_zone = "${var.availability_zone_2}"

  tags {
    Name = "chatops-${var.product}-${var.environment}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "consul-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
    Layer       = "consul"
  }
}

resource "aws_route" "default" {
  route_table_id         = "${aws_route_table.default.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table_association" "default" {
  subnet_id      = "${aws_subnet.av1.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_alb" "default" {
  name            = "${var.product}-${var.environment}"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${aws_subnet.av1.id}", "${aws_subnet.av2.id}"]
  idle_timeout    = 4000

  enable_deletion_protection = false

  tags {
    Environment = "production"
  }
}

resource "aws_route53_record" "environment" {
  count   = "1"
  zone_id = "${var.aws_route53_zone_id}"
  name    = "${var.product}-${var.environment}"
  type    = "CNAME"
  ttl     = 60
  records = ["${aws_alb.default.dns_name}"]
}


resource "aws_security_group" "alb" {
  name = "alb"

  description = "alb security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "alb-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
  }
}

variable "monitoring_cidrs" {
  type = "list"

  default = [
    "216.144.250.150/32",
    "69.162.124.226/32",
    "69.162.124.227/32",
    "69.162.124.228/32",
    "69.162.124.229/32",
    "69.162.124.230/32",
    "69.162.124.231/32",
    "69.162.124.232/32",
    "69.162.124.233/32",
    "69.162.124.234/32",
    "69.162.124.235/32",
    "69.162.124.236/32",
    "69.162.124.237/32",
    "63.143.42.242/32",
    "63.143.42.243/32",
    "63.143.42.244/32",
    "63.143.42.245/32",
    "63.143.42.246/32",
    "63.143.42.247/32",
    "63.143.42.248/32",
    "63.143.42.249/32",
    "63.143.42.250/32",
    "63.143.42.251/32",
    "63.143.42.252/32",
    "63.143.42.253/32",
    "46.137.190.132/32",
    "122.248.234.23/32",
    "188.226.183.141/32",
    "178.62.52.237/32",
    "54.79.28.129/32",
    "54.94.142.218/32",
    "104.131.107.63/32",
    "54.67.10.127/32",
    "54.64.67.106/32",
    "159.203.30.41/32",
    "46.101.250.135/32",
    "18.221.56.27/32",
    "52.60.129.180/32",
    "159.89.8.111/32",
    "146.185.143.14/32",
    "139.59.173.249/32",
    "165.227.83.148/32",
    "128.199.195.156/32",
    "138.197.150.151/32",
  ]
}
