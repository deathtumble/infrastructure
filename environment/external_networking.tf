resource "aws_subnet" "av1" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "10.0.0.0/25"
  availability_zone = "${var.availability_zone_1}"

  tags {
    Name = "av1-${var.product}-${var.environment}"
  }
}

resource "aws_subnet" "av2" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "10.0.0.128/25"
  availability_zone = "${var.availability_zone_2}"

  tags {
    Name = "av1-${var.product}-${var.environment}"
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

resource "aws_alb_target_group" "default" {
  name     = "default"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  tags {
    Name          = "default-${var.environment}"
    Product       = "${var.product}"
    Environment   = "${var.environment}"
  }
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = "${aws_alb.default.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "environment" {
  count   = "1"
  zone_id = "${var.aws_route53_zone_id}"
  name    = "${var.environment}"
  type    = "NS"
  ttl     = 60
  records = [
    "${aws_route53_zone.environment.name_servers.0}",
    "${aws_route53_zone.environment.name_servers.1}",
    "${aws_route53_zone.environment.name_servers.2}",
    "${aws_route53_zone.environment.name_servers.3}"
  ]
}

resource "aws_route53_zone" "environment" {
  name = "${var.environment}.${var.root_domain_name}"

  tags {
    Environment = "${var.environment}"
  }
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
    from_port   = 8500
    to_port     = 8500
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
  ]
}
