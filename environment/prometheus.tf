module "prometheus" {
  source = "../ephemeralinstance"

  role = "prometheus"

  globals = "${var.globals}"

  vpc_security_group_ids = [
    "${aws_security_group.prometheus.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
  ]

  instance_type        = "t2.medium"

  // globals
  aws_subnet_id            = "${aws_subnet.av1.id}"
  vpc_id                   = "${aws_vpc.default.id}"
  gateway_id               = "${aws_internet_gateway.default.id}"
  availability_zone        = "${var.availability_zone_1}"
  ami_id                   = "${var.ecs_ami_id}"
}

module "prometheus-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port    = "9090"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/"
  task_definition      = "prometheus-${local.environment}:${aws_ecs_task_definition.prometheus.revision}"
  task_status          = "${var.prometheus_task_status}"
  aws_lb_listener_default_arn = "${aws_alb_listener.default.arn}"
  aws_lb_listener_rule_priority = 93
  aws_route53_environment_zone_id      = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name = "${aws_alb.default.dns_name}"
  vpc_id                   = "${aws_vpc.default.id}"
  role = "prometheus"
  product = "${local.product}"
  environment = "${local.environment}"
  root_domain_name = "${local.root_domain_name}"
}

resource "aws_ecs_task_definition" "prometheus" {
  family       = "prometheus-${local.environment}"
  network_mode = "host"

  container_definitions = <<DEFINITION
    [
        {
            "name": "prometheus",
            "cpu": 0,
            "essential": true,
            "image": "quay.io/prometheus/prometheus",
            "memory": 500,
            "dnsServers": ["127.0.0.1"],
            "portMappings": [
                {
                  "hostPort": 9090,
                  "containerPort": 9090,
                  "protocol": "tcp"
                }
            ]
        }
    ]
    DEFINITION
}

resource "aws_security_group" "prometheus" {
  name = "prometheus"

  description = "prometheus security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "prometheus-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
    Layer       = "prometheus"
  }
}