module "nexus-instance" {
  source = "../ebs-instance"

  role = "nexus"

  globals = "${var.globals}"

  vpc_security_group_ids = [
    "${aws_security_group.nexus.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
    "${aws_security_group.cadvisor.id}",
    "${aws_security_group.goss.id}",
  ]

  instance_type        = "t2.medium"

  volume_id = "${local.nexus_volume_id}"

  // globals
  vpc_id                   = "${aws_vpc.default.id}"
  availability_zone        = "${var.availability_zone_1}"
  ami_id                   = "${var.ecs_ami_id}"
}

module "nexus-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port    = "8081"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/service/metrics/healthcheck"
  task_definition      = "nexus-${local.environment}:${aws_ecs_task_definition.nexus.revision}"
  task_status          = "${var.nexus_task_status}"
  aws_lb_listener_default_arn = "${aws_alb_listener.default.arn}"
  aws_lb_listener_rule_priority = 95
  aws_route53_environment_zone_id      = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name = "${aws_alb.default.dns_name}"
  vpc_id                   = "${aws_vpc.default.id}"
  role = "nexus"
  product = "${local.product}"
  environment = "${local.environment}"
  root_domain_name = "${local.root_domain_name}"

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
