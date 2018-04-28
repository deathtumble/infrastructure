module "nexus" {
  source = "./role"

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
  task_definition      = "nexus:${aws_ecs_task_definition.nexus.revision}"
  task_status          = "${var.nexus_task_status}"
  instance_type        = "t2.medium"

  volume_id = "${var.nexus_volume_id}"

  // globals
  aws_alb_arn              = "${aws_alb.default.arn}"
  key_name                 = "${var.key_name}"
  aws_subnet_id            = "${aws_subnet.av1.id}"
  vpc_id                   = "${aws_vpc.default.id}"
  gateway_id               = "${aws_internet_gateway.default.id}"
  availability_zone        = "${var.availability_zone_1}"
  ami_id                   = "${var.ecs_ami_id}"
  product                  = "${var.product}"
  environment              = "${var.environment}"
  aws_route53_zone_id      = "${var.aws_route53_zone_id}"
  aws_alb_default_dns_name = "${aws_alb.default.dns_name}"
  root_domain_name         = "${var.root_domain_name}"
}

data "template_file" "nexus" {
  template = "${file("files/nexus_container.tpl")}"
}

data "template_file" "collectd-nexus" {
  template = "${file("files/collectd.tpl")}"

  vars {
    graphite_prefix = "${var.product}.${var.environment}.nexus."
  }
}

resource "aws_ecs_task_definition" "nexus" {
  family       = "nexus"
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
    cidr_blocks = "${concat(var.monitoring_cidrs, list(var.admin_cidr))}"
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
    Name        = "nexus-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
    Layer       = "nexus"
  }
}
