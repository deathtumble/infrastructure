module "consul-instance" {
  source = "../no-ebs-instance"

  count             = "3"
  instance_type     = "t2.small"
  vpc_id            = "${local.vpc_id}"
  availability_zone = "${local.availability_zone}"
  subnet_id         = "${local.subnet_id}"
  ami_id            = "${local.ecs_ami_id}"
  cluster_name      = "consul"
  consul-service    = "no"

  vpc_security_group_ids = [
    "${aws_security_group.consul.id}",
    "${local.aws_security_group_os_id}",
  ]

  globals = "${var.globals}"
}

module "consul-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port               = "8500"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/v1/agent/checks"
  task_definition                 = "consul-${local.environment}:${aws_ecs_task_definition.consul.revision}"
  task_status                     = "${var.task_status}"
  desired_task_count              = "3"
  aws_lb_listener_rule_priority   = 94
  aws_lb_listener_default_arn     = "${local.aws_lb_listener_default_arn}"
  aws_route53_environment_zone_id = "${local.aws_route53_environment_zone_id}"
  aws_alb_default_dns_name        = "${local.aws_alb_default_dns_name}"
  vpc_id                          = "${local.vpc_id}"
  product                         = "${local.product}"
  environment                     = "${local.environment}"
  root_domain_name                = "${local.root_domain_name}"
  ecs_iam_role                    = "${local.ecs_iam_role}"
  role                            = "consul"
  cluster_name                    = "consul"
}

resource "aws_ecs_cluster" "consul" {
  name = "consul-${local.environment}"
}

resource "aws_ecs_task_definition" "consul" {
  family       = "consul-${local.environment}"
  network_mode = "host"

  container_definitions = <<DEFINITION
    [
        {
            "name": "consul",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/consul:${var.docker_tag}",
            "memory": 500,
            "environment": [
                {
                    "Name": "CONSUL_LOCAL_CONFIG",
                    "Value": "{\"skip_leave_on_interrupt\": true, \"telemetry\": {\"metrics_prefix\":\"${local.product}.${local.environment}.consul.server\"}}"
                },
                {
                    "Name": "CONSUL_BIND_INTERFACE",
                    "Value": "eth0"
                }, 
                {
                    "Name": "CONSUL_CLIENT_INTERFACE",
                    "Value": "eth0"
                },
                {
                    "Name": "CONSUL_ALLOW_PRIVILEGED_PORTS",
                    "Value": ""
                }
            ],
            "command": [
                "agent",
                "-server",
                "-dns-port=53",
                "-recursor=${var.dns_ip}",
                "-bootstrap-expect=3",
                "-retry-join",
                "provider=aws tag_key=ConsulCluster tag_value=${local.product}-${local.environment}",
                "-ui"
            ],
            "portMappings": [
                {
                  "hostPort": 8300,
                  "containerPort": 8300,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 8301,
                  "containerPort": 8301,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 8301,
                  "containerPort": 8301,
                  "protocol": "udp"
                },
                {
                  "hostPort": 8302,
                  "containerPort": 8302,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 8302,
                  "containerPort": 8302,
                  "protocol": "udp"
                },
                {
                  "hostPort": 8500,
                  "containerPort": 8500,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 53,
                  "containerPort": 53,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 53,
                  "containerPort": 53,
                  "protocol": "udp"
                }
            ]
        }
    ]
    DEFINITION
}

resource "aws_security_group" "consul" {
  name = "consul-${local.product}-${local.environment}"

  vpc_id      = "${local.vpc_id}"

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${local.admin_cidr}", "${local.vpc_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${local.vpc_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${local.vpc_cidr}"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["${local.vpc_cidr}"]
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["${local.vpc_cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${local.vpc_cidr}", "${local.admin_cidr}"]
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["${local.vpc_cidr}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${local.vpc_cidr}", "${local.admin_cidr}"]
  }

  tags {
    Name        = "consul-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
  }
}
