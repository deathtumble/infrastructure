module "default-instance" {
  source = "../modules/no-ebs-instance"

  instance_count    = "3"
  instance_type     = "t2.medium"
  vpc_id            = module.vpc.vpc_id
  availability_zone = module.vpc.az1_availability_zone
  subnet_id         = module.vpc.az1_subnet_id
  ami_id            = var.ecs_ami_id
  cluster_name      = "default"
  context           = var.context

  vpc_security_group_ids = [
    module.aws-proxy.aws_security_group_id,
    module.dashing.aws_security_group_id,
    module.concourse_web.aws_security_group_id,
    aws_security_group.os.id,
  ]
}

module "default-efs-instance" {
  source = "../modules/ebs-instance"

  instance_count    = "5"
  instance_type     = "t2.medium"
  vpc_id            = module.vpc.vpc_id
  availability_zone = module.vpc.az1_availability_zone
  subnet_id         = module.vpc.az1_subnet_id
  ami_id            = var.ecs_ami_id
  efs_id            = var.context.region.efs_id
  cluster_name      = "default-efs"	
  context = var.context

  vpc_security_group_ids = [
    module.prometheus.aws_security_group_id,
    module.nexus.aws_security_group_id,
    module.grafana.aws_security_group_id,
    aws_security_group.logstash.id,
    aws_security_group.os.id,
  ]
}

module "consul-instance" {
  source = "../modules/no-ebs-instance"

  instance_count    = "3"
  instance_type     = "t2.small"
  vpc_id            = module.vpc.vpc_id
  availability_zone = module.vpc.az1_availability_zone
  subnet_id         = module.vpc.az1_subnet_id
  ami_id            = var.ecs_ami_id
  cluster_name      = "consul"
  consul-service    = "no"
  context           = var.context

  vpc_security_group_ids = [
    module.consul.aws_security_group_id,
    aws_security_group.os.id,
  ]
}

resource "aws_ecs_cluster" "default-efs" {
  name = "default-efs-${var.context.environment.name}"
}

resource "aws_ecs_cluster" "default" {
  name = "default-${var.context.environment.name}"
}

resource "aws_security_group" "os" {
  name = "os-${var.context.product.name}-${var.context.environment.name}"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, "0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", var.vpc_cidr]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "os-${var.context.product.name}-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alb" {
  name = "alb"

  description = "alb security group"
  vpc_id      = module.vpc.vpc_id

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

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-${var.context.product.name}-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

