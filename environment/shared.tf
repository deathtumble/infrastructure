module "default-instance" {
  source = "../modules/no-ebs-instance"

  count             = "3"
  instance_type     = "t2.medium"
  vpc_id            = "${module.vpc.vpc_id}"
  availability_zone = "${module.vpc.az1_availability_zone}"
  subnet_id         = "${module.vpc.az1_subnet_id}"
  ami_id            = "${var.ecs_ami_id}"
  cluster_name      = "default"

  vpc_security_group_ids = [
    "${module.aws-proxy.aws_security_group_id}",
    "${module.dashing.aws_security_group_id}",
    "${module.concourse_web.aws_security_group_id}",
    "${aws_security_group.os.id}"
  ]

  globals = "${var.globals}"
}

module "default-efs-instance" {
  source = "../modules/ebs-instance"

  count             = "3"
  instance_type     = "t2.medium"
  vpc_id            = "${module.vpc.vpc_id}"
  availability_zone = "${module.vpc.az1_availability_zone}"
  subnet_id         = "${module.vpc.az1_subnet_id}"
  ami_id            = "${var.ecs_ami_id}"
  efs_id            = "${local.efs_id}"
  cluster_name      = "default-efs"

  vpc_security_group_ids = [
    "${module.prometheus.aws_security_group_id}",
    "${module.nexus.aws_security_group_id}",
    "${module.grafana.aws_security_group_id}",
    "${aws_security_group.os.id}"
  ]

  globals = "${var.globals}"
}


resource "aws_ecs_cluster" "default-efs" {
  name = "default-efs-${local.environment}"
}

resource "aws_ecs_cluster" "default" {
  name = "default-${local.environment}"
}

resource "aws_security_group" "os" {
  name = "os-${local.product}-${local.environment}"

  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${local.admin_cidr}"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${local.admin_cidr}", "${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "os-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
  }
  
  lifecycle {
    create_before_destroy = true
  }  
}

resource "aws_security_group" "alb" {
  name = "alb"

  description = "alb security group"
  vpc_id = "${module.vpc.vpc_id}"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "alb-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }  
}

