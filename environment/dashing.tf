module "dashing-instance" {
  source = "../ephemeralinstance"

  role              = "dashing"
  instance_type     = "t2.medium"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${var.availability_zone_1}"
  ami_id            = "${var.ecs_ami_id}"

  vpc_security_group_ids = [
    "${aws_security_group.dashing.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.cadvisor.id}",
    "${aws_security_group.consul-client.id}",
  ]

  globals = "${var.globals}"
}

module "dashing-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port               = "80"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/favicon.ico"
  task_definition                 = "dashing-${local.environment}:${aws_ecs_task_definition.dashing.revision}"
  task_status                     = "${var.dashing_task_status}"
  aws_lb_listener_default_arn     = "${aws_alb_listener.default.arn}"
  aws_lb_listener_rule_priority   = 97
  aws_route53_environment_zone_id = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name        = "${aws_alb.default.dns_name}"
  vpc_id                          = "${aws_vpc.default.id}"
  role                            = "dashing"
  product                         = "${local.product}"
  environment                     = "${local.environment}"
  root_domain_name                = "${local.root_domain_name}"
}

resource "aws_ecs_task_definition" "dashing" {
  family       = "dashing-${local.environment}"
  network_mode = "bridge"

  volume {
    name      = "consul_config"
    host_path = "/etc/consul"
  }

  volume {
    name      = "goss_config"
    host_path = "/etc/goss"
  }

  container_definitions = <<DEFINITION
    [
        {
            "name": "dashing",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/smashing:${var.dashing_docker_tag}",
            "memory": 200,
            "environment": [
                {
                    "Name": "PORT",
                    "Value": "80"
                }
             ], 
            "portMappings": [
                {
                  "hostPort": 80,
                  "containerPort": 80,
                  "protocol": "tcp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "consul_config",
                  "containerPath": "/etc/consul",
                  "readOnly": false
                },
                {
                  "sourceVolume": "goss_config",
                  "containerPath": "/etc/goss",
                  "readOnly": false
                }
            ]
        },
        {
            "name": "aws-proxy",
            "cpu": 0,
            "essential": false,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/aws-proxy:${var.aws_proxy_docker_tag}",
            "memory": 500,
            "environment": [
                {
                    "Name": "AWS_ACCESS_KEY_ID",
                    "Value": "${local.aws-proxy_access_id}"
                },
                {
                    "Name": "AWS_SECRET_ACCESS_KEY",
                    "Value": "${local.aws-proxy_secret_access_key}"
                },
                {
                    "Name": "aws.region",
                    "Value": "${var.region}"
                }
             ], 
            "portMappings": [
                {
                  "hostPort": 8081,
                  "containerPort": 8080,
                  "protocol": "tcp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "consul_config",
                  "containerPath": "/etc/consul",
                  "readOnly": false
                },
                {
                  "sourceVolume": "goss_config",
                  "containerPath": "/etc/goss",
                  "readOnly": false
                }
            ]
        }
    ]
    DEFINITION
}

resource "aws_security_group" "dashing" {
  name = "dashing"

  description = "dashing security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${local.admin_cidr}", "${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "dashing-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
    Layer       = "dashing"
  }
}
