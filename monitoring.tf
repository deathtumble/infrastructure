module "monitoring" {
  source = "./role"

  role = "monitoring"

  vpc_security_group_ids = [
    "${aws_security_group.graphite.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
  ]

  elb_security_group   = "${aws_security_group.grafana.id}"
  elb_instance_port    = "3000"
  elb_port             = "80"
  healthcheck_port     = "3000"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/api/health"
  task_definition      = "monitoring:${aws_ecs_task_definition.monitoring.revision}"
  desired_count        = "1"

  volume_id = "vol-0a53b71d35611d427"

  // todo remove need to specify    
  cidr_block = "${var.monitoring_subnet}"
  private_ip = "10.0.0.36"

  // globals
  vpc_id                     = "${aws_vpc.default.id}"
  gateway_id                 = "${aws_internet_gateway.default.id}"
  availability_zone          = "${var.availability_zone}"
  ami_id                     = "${var.ecs_ami_id}"
  ecosystem                  = "${var.ecosystem}"
  environment                = "${var.environment}"
  aws_route53_record_zone_id = "${aws_route53_zone.root.zone_id}"
}

data "template_file" "collectd-monitoring" {
  template = "${file("files/collectd.tpl")}"

  vars {
    graphite_prefix = "${var.ecosystem}.${var.environment}.monitoring."
  }
}

resource "aws_ecs_task_definition" "monitoring" {
  family       = "monitoring"
  network_mode = "host"

  volume {
    name      = "consul_config"
    host_path = "/opt/consul/conf"
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

  volume {
    name      = "graphite_config"
    host_path = "/opt/mount1/graphite/conf"
  }

  volume {
    name      = "graphite_stats_storage"
    host_path = "/opt/mount1/graphite/storage"
  }

  volume {
    name      = "nginx_config"
    host_path = "/opt/mount1/nginx_config"
  }

  volume {
    name      = "statsd_config"
    host_path = "/opt/mount1/statsd_config"
  }

  volume {
    name      = "graphite_logrotate_config"
    host_path = "/etc/logrotate.d"
  }

  volume {
    name      = "graphite_log_files"
    host_path = "/opt/mount1/graphite_log_files"
  }

  container_definitions = <<DEFINITION
	[
        ${data.template_file.consul_agent.rendered},
        ${data.template_file.collectd-monitoring.rendered},
		{
		    "name": "graphite-statsd",
		    "cpu": 0,
		    "essential": true,
		    "image": "graphiteapp/graphite-statsd:latest",
		    "memory": 400,
		    "portMappings": [
		        {
		          "hostPort": 80,
		          "containerPort": 80,
		          "protocol": "tcp"
		        },
                {
                  "hostPort": 82,
                  "containerPort": 82,
                  "protocol": "tcp"
                },
		        {
		          "hostPort": 2003,
		          "containerPort": 2003,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2004,
		          "containerPort": 2004,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2023,
		          "containerPort": 2023,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2024,
		          "containerPort": 2024,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 8125,
		          "containerPort": 8125,
		          "protocol": "udp"
		        },
		        {
		          "hostPort": 8126,
		          "containerPort": 8126,
		          "protocol": "udp"
		        }
		    ],
			"mountPoints": [
                {
                  "sourceVolume": "graphite_config",
                  "containerPath": "/opt/graphite/conf",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_stats_storage",
                  "containerPath": "/opt/graphite/storage",
                  "readOnly": false
                },
                {
                  "sourceVolume": "nginx_config",
                  "containerPath": "/etc/nginx",
                  "readOnly": false
                },
                {
                  "sourceVolume": "statsd_config",
                  "containerPath": "/opt/statsd",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_logrotate_config",
                  "containerPath": "/etc/logrotate.d",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_log_files",
                  "containerPath": "/var/log/graphite",
                  "readOnly": false
                }
            ]
        },
		{
		    "name": "grafana",
		    "cpu": 0,
		    "essential": true,
		    "image": "grafana/grafana",
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
  name = "graphite-${var.nameTag}"

  vpc_id     = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  ingress {
    from_port   = 2003
    to_port     = 2003
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "udp"
    cidr_blocks = ["${var.ecosystem_cidr}", "${var.admin_cidr}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}", "${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}", "${var.admin_cidr}"]
  }

  tags {
    Name        = "graphite-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
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
    cidr_blocks = "${var.admin_cidrs}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "grafana-${var.nameTag}"
    Ecosystem   = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer       = "grafana"
  }
}
