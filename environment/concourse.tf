module "concourse-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port               = "8080"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/public/images/favicon.png"
  task_definition                 = "concourse-${local.environment}:${aws_ecs_task_definition.concourse.revision}"
  task_status                     = "${var.concourse_task_status}"
  aws_lb_listener_rule_priority   = 98
  aws_lb_listener_default_arn     = "${aws_alb_listener.default.arn}"
  aws_route53_environment_zone_id = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name        = "${aws_alb.default.dns_name}"
  vpc_id                          = "${aws_vpc.default.id}"
  role                            = "concourse"
  product                         = "${local.product}"
  environment                     = "${local.environment}"
  root_domain_name                = "${local.root_domain_name}"
  ecs_iam_role                    = "${local.ecs_iam_role}"
  cluster_name                    = "default"
}

resource "aws_ecs_task_definition" "concourse" {
  family       = "concourse-${local.environment}"
  network_mode = "host"
  depends_on   = ["aws_db_instance.concourse"]

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
            "name": "concourse",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/concourse-web:${var.concourse_docker_tag}",
            "memory": 500,
            "dnsServers": ["127.0.0.1"],
            "portMappings": [
                {
                  "hostPort": 8080,
                  "containerPort": 8080,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 2222,
                  "containerPort": 2222,
                  
                  "protocol": "tcp"
                }
            ],
            "environment": [
                {
                    "Name": "CONCOURSE_BASIC_AUTH_USERNAME",
                    "Value": "concourse"
                }, 
                {
                    "Name": "CONCOURSE_BASIC_AUTH_PASSWORD",
                    "Value": "${local.concourse_password}"
                }, 
                {
                    "Name": "CONCOURSE_EXTERNAL_URL",
                    "Value": "http://concourse.${local.environment}.${local.root_domain_name}"
                }, 
                {
                    "Name": "CONCOURSE_POSTGRES_HOST",
                    "Value": "${aws_db_instance.concourse.address}"
                }, 
                {
                    "Name": "CONCOURSE_POSTGRES_USER",
                    "Value": "concourse"
                }, 
                {
                    "Name": "CONCOURSE_POSTGRES_PASSWORD",
                    "Value": "${local.concourse_postgres_password}"
                }, 
                {
                    "Name": "CONCOURSE_POSTGRES_DATABASE",
                    "Value": "concourse"
                }, 
                {
                    "Name": "CONCOURSE_PORT",
                    "Value": "8085"
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

resource "aws_security_group" "concourse" {
  name = "concourse"

  description = "concourse security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 2222
    to_port     = 2222
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
    Name        = "concourse-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
    Layer       = "concourse"
  }
}
