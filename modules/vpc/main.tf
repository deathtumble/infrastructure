resource "aws_vpc" "default" {
  cidr_block                       = var.context.vpcs[var.vpc_name].cidr
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name        = "${var.context.product.name}-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name        = "${var.context.product.name}-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
  }
}

resource "aws_network_acl" "default" {
  vpc_id = aws_vpc.default.id

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

  tags = {
    Name        = "${var.context.product.name}-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name        = "${var.context.product.name}-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
  }
}

resource "aws_main_route_table_association" "default" {
  vpc_id         = aws_vpc.default.id
  route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "av1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.context.vpcs[var.vpc_name].azs["1st"].subnet
  availability_zone = var.context.vpcs[var.vpc_name].azs["1st"].name

  tags = {
    Name = "av1-${var.context.product.name}-${var.context.environment.name}"
  }
}

resource "aws_subnet" "av2" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.context.vpcs[var.vpc_name].azs["2nd"].subnet
  availability_zone = var.context.vpcs[var.vpc_name].azs["2nd"].name

  tags = {
    Name = "av1-${var.context.product.name}-${var.context.environment.name}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name        = "consul-${var.context.product.name}-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
    Layer       = "consul"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.av1.id
  route_table_id = aws_route_table.default.id
}

resource "aws_alb" "default" {
  name            = "${var.context.product.name}-${var.context.environment.name}"
  internal        = false
  security_groups = [var.aws_security_group_alb_id]
  subnets         = [aws_subnet.av1.id, aws_subnet.av2.id]
  idle_timeout    = 4000

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_alb_target_group" "default" {
  name     = "default-${var.context.environment.name}"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id

  tags = {
    Name        = "default-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
  }
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = aws_alb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.default.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "environment" {
  count   = "1"
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.context.environment.name
  type    = "NS"
  ttl     = 60

  records = [
    aws_route53_zone.environment.name_servers[0],
    aws_route53_zone.environment.name_servers[1],
    aws_route53_zone.environment.name_servers[2],
    aws_route53_zone.environment.name_servers[3],
  ]
}

resource "aws_route53_zone" "environment" {
  name = "${var.context.environment.name}.${var.context.product.root_domain_name}"

  tags = {
    Environment = var.context.environment.name
  }
}

data "aws_route53_zone" "selected" {
  name = "${var.context.product.root_domain_name}."
}

