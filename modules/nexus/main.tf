module "nexus-instance" {
  source = "../ebs-instance"

  instance_type             = "t2.medium"
  vpc_id                    = "${local.vpc_id}"
  availability_zone         = "${local.availability_zone}"
  subnet_id                 = "${local.subnet_id}"
  ami_id                    = "${local.ecs_ami_id}"
  efs_id                    = "${local.efs_id}"
  cluster_name              = "nexus"
  
  vpc_security_group_ids = [
    "${aws_security_group.nexus.id}",
    "${local.aws_security_group_os_id}",
  ]

  globals = "${var.globals}"
}

module "nexus-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port               = "8081"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/service/metrics/healthcheck"
  task_definition                 = "nexus-${local.environment}:${aws_ecs_task_definition.nexus.revision}"
  task_status                     = "${var.task_status}"
  aws_lb_listener_rule_priority   = 95
  aws_lb_listener_default_arn     = "${local.aws_lb_listener_default_arn}"
  aws_route53_environment_zone_id = "${local.aws_route53_environment_zone_id}"
  aws_alb_default_dns_name        = "${local.aws_alb_default_dns_name}"
  vpc_id                          = "${local.vpc_id}"
  product                         = "${local.product}"
  environment                     = "${local.environment}"
  root_domain_name                = "${local.root_domain_name}"
  ecs_iam_role                    = "${local.ecs_iam_role}"
  role                            = "nexus"
  cluster_name                    = "nexus"
}

resource "aws_ecs_cluster" "nexus" {
  name = "nexus-${local.environment}"
}

resource "aws_ecs_task_definition" "nexus" {
  family       = "nexus-${local.environment}"
  network_mode = "bridge"

  volume {
    name      = "nexus-data"
    host_path = "/opt/mount1/nexus"
  }

  volume {
    name      = "consul_config"
    host_path = "/etc/consul"
  }

  container_definitions = <<DEFINITION
    [
        {
            "name": "nexus",
            "cpu": 0,
            "essential": true,
            "image": "sonatype/nexus3:3.10.0",
            "memory": 2000,
            "portMappings": [
                {
                  "hostPort": 8081,
                  "containerPort": 8081,
                  "protocol": "tcp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "nexus-data",
                  "containerPath": "/nexus-data",
                  "readOnly": false
                }
            ]
        }
    ]
    DEFINITION
}

resource "aws_security_group" "nexus" {
  name = "nexus"

  description = "nexus security group"
  vpc_id      = "${local.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${local.admin_cidr}"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
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
    Name        = "nexus-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
    Layer       = "nexus"
  }
}
