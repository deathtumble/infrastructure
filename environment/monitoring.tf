module "monitoring-instance" {
  source = "../ebs-instance"

  role = "monitoring"

  globals = "${var.globals}"

  vpc_security_group_ids = [
    "${aws_security_group.graphite.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.cadvisor.id}",
    "${aws_security_group.consul-client.id}",
    "${aws_security_group.goss.id}",
  ]

  volume_id = "${local.monitoring_volume_id}"

  // globals
  vpc_id                   = "${aws_vpc.default.id}"
  availability_zone        = "${var.availability_zone_1}"
  ami_id                   = "${var.ecs_ami_id}"
}

module "monitoring-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port    = "3000"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/api/health"
  task_definition      = "monitoring-${local.environment}:${aws_ecs_task_definition.monitoring.revision}"
  task_status          = "${var.monitoring_task_status}"
  aws_lb_listener_default_arn = "${aws_alb_listener.default.arn}"
  aws_lb_listener_rule_priority = 96
  aws_route53_environment_zone_id      = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name = "${aws_alb.default.dns_name}"
  vpc_id                   = "${aws_vpc.default.id}"
  role = "monitoring"
  product = "${local.product}"
  environment = "${local.environment}"
  root_domain_name = "${local.root_domain_name}"
}

resource "aws_ecs_task_definition" "monitoring" {
  family       = "monitoring-${local.environment}"
  network_mode = "host"

  volume {
    name      = "consul_config"
    host_path = "/etc/consul"
  }

  volume {
    name      = "grafana_data"
    host_path = "/opt/mount1/grafana"
  }

  volume {
    name      = "grafana_plugins"
    host_path = "/opt/mount1/grafana/plugins"
  }

  volume {
    name      = "grafana_logs"
    host_path = "/opt/mount1/grafana_logs"
  }

  container_definitions = <<DEFINITION
	[
    	{
		    "name": "monitoring",
		    "cpu": 0,
		    "essential": true,
		    "image": "grafana/grafana:5.1.0",
		    "memory": 500,
		    "portMappings": [
		        {
		          "hostPort": 3000,
		          "containerPort": 3000,
		          "protocol": "udp"
		        }
		    ],
		    "mountPoints": [
                {
                  "sourceVolume": "grafana_data",
                  "containerPath": "/var/lib/grafana/",
                  "readOnly": false
                },
                {
                  "sourceVolume": "grafana_plugins",
                  "containerPath": "/var/lib/grafana/plugins",
                  "readOnly": false
                },
                {
                  "sourceVolume": "grafana_logs",
                  "containerPath": "/var/log/grafana",
                  "readOnly": false
                }
            ]
      	}
	]
    DEFINITION
}

resource "aws_security_group" "graphite" {
  name = "graphite-${local.product}-${local.environment}"

  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 2003
    to_port     = 2003
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}", "${local.admin_cidr}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${local.admin_cidr}"]
  }

  tags {
    Name        = "graphite-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
  }
}

resource "aws_security_group" "grafana" {
  name = "grafana"

  description = "grafana security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${local.admin_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "grafana-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
    Layer       = "grafana"
  }
}
