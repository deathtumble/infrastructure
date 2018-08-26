module "grafana-instance" {
  source = "../ebs-instance"

  role              = "grafana"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${var.availability_zone_1}"
  ami_id            = "${var.ecs_ami_id}"
  cluster_name      = "grafana"
  volume_id         = "${local.grafana_volume_id}"

  vpc_security_group_ids = [
    "${aws_security_group.os.id}",
    "${aws_security_group.grafana.id}",
  ]

  globals = "${var.globals}"
}

module "grafana-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port               = "3000"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/api/health"
  task_definition                 = "grafana-${local.environment}:${aws_ecs_task_definition.grafana.revision}"
  task_status                     = "${var.grafana_task_status}"
  aws_lb_listener_default_arn     = "${aws_alb_listener.default.arn}"
  aws_lb_listener_rule_priority   = 96
  aws_route53_environment_zone_id = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name        = "${aws_alb.default.dns_name}"
  vpc_id                          = "${aws_vpc.default.id}"
  role                            = "grafana"
  product                         = "${local.product}"
  environment                     = "${local.environment}"
  root_domain_name                = "${local.root_domain_name}"
  ecs_iam_role                    = "${local.ecs_iam_role}"
  cluster_name                    = "grafana"
}

resource "aws_ecs_cluster" "grafana" {
  name = "grafana-${local.environment}"
}

resource "aws_ecs_task_definition" "grafana" {
  family       = "grafana-${local.environment}"
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
		    "name": "grafana",
		    "cpu": 0,
		    "essential": true,
		    "image": "grafana/grafana:5.1.0",
		    "memory": 500,
            "dnsServers": ["127.0.0.1"],
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

resource "aws_security_group" "grafana" {
  name = "grafana"

  description = "grafana security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 3000
    to_port     = 3000
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
