module "nexus" {
  source = "../role"

  role = "nexus"

  vpc_security_group_ids = [
    "${aws_security_group.nexus.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
    "${aws_security_group.goss.id}",
  ]

  elb_instance_port    = "8081"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/service/metrics/healthcheck"
  task_definition      = "nexus-${local.environment}:${aws_ecs_task_definition.nexus.revision}"
  task_status          = "${var.nexus_task_status}"
  instance_type        = "t2.medium"

  volume_id = "${local.nexus_volume_id}"

  // globals
  aws_lb_listener_default_arn = "${aws_alb_listener.default.arn}"
  aws_lb_listener_rule_priority = 95
  key_name = "${local.key_name}"
  product = "${local.product}"
  environment = "${local.environment}"
  root_domain_name = "${local.root_domain_name}"
  aws_subnet_id            = "${aws_subnet.av1.id}"
  vpc_id                   = "${aws_vpc.default.id}"
  gateway_id               = "${aws_internet_gateway.default.id}"
  availability_zone        = "${var.availability_zone_1}"
  ami_id                   = "${var.ecs_ami_id}"
  aws_route53_zone_id      = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name = "${aws_alb.default.dns_name}"
}

data "template_file" "collectd-nexus" {
  template = "${file("${path.module}/files/collectd.tpl")}"

  vars {
    graphite_prefix = "${local.product}.${local.environment}.nexus."
    collectd_docker_tag = "${var.collectd_docker_tag}"
  }
}

resource "aws_ecs_task_definition" "nexus" {
  family       = "nexus-${local.environment}"
  network_mode = "host"

  volume {
    name      = "nexus-data"
    host_path = "/opt/mount1/nexus"
  }

  volume {
    name      = "consul_config"
    host_path = "/opt/consul/conf"
  }

  container_definitions = <<DEFINITION
	[
        ${data.template_file.consul_agent.rendered},
        ${data.template_file.collectd-nexus.rendered},
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
            "portMappings": [
                {
                  "hostPort": 8082,
                  "containerPort": 8082,
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
  vpc_id      = "${aws_vpc.default.id}"

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
