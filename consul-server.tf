resource "aws_instance" "consul-server" {
  count                   = "${var.consul_server_count}"
  ami                     = "${var.ecs_ami_id}"
  availability_zone       = "${var.availability_zone_1}"
  tenancy                 = "default"
  ebs_optimized           = "false"
  disable_api_termination = "false"
  instance_type           = "t2.small"
  key_name                = "${var.key_name}"
  monitoring              = "false"

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-server.id}",
  ]

  subnet_id                   = "${aws_subnet.av1.id}"
  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=consul-server
HOST_NAME=consul-${var.product}-${var.environment}-${lookup(var.consul_server_instance_names, count.index)}
EOF

  tags {
    Name          = "consul-${lookup(var.consul_server_instance_names, count.index)}"
    Product       = "${var.product}"
    Environment   = "${var.environment}"
    ConsulCluster = "${var.product}-${var.environment}"
  }
}

resource "aws_elb_attachment" "consul-server" {
  count    = "${var.consul_server_count}"
  elb      = "${aws_elb.consului.id}"
  instance = "${aws_instance.consul-server.*.id[count.index]}"
}

resource "aws_ecs_cluster" "consul-server" {
  name = "consul-server"
}

resource "aws_ecs_service" "consul-server" {
  name            = "consul-server"
  cluster         = "consul-server"
  task_definition = "consul-server:${aws_ecs_task_definition.consul-server.revision}"
  depends_on      = ["aws_ecs_cluster.consul-server", "aws_ecs_task_definition.consul-server"]
  desired_count   = 2
}

resource "aws_ecs_task_definition" "consul-server" {
  family       = "consul-server"
  network_mode = "host"

  container_definitions = <<DEFINITION
    [
        {
            "name": "collectd",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:${var.collectd_docker_tag}",
            "memory": 500,
            "dnsServers": ["127.0.0.1"],
            "environment": [
                {
                    "Name": "GRAPHITE_HOST",
                    "Value": "graphite.service.consul"
                }, 
                {
                    "Name": "GRAPHITE_PREFIX",
                    "Value": "${var.product}.${var.environment}.consul."
                }
            ]
        },
        {
            "name": "consul-server",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/consul:${var.consul_docker_tag}",
            "memory": 500,
            "environment": [
                {
                    "Name": "CONSUL_LOCAL_CONFIG",
                    "Value": "{\"skip_leave_on_interrupt\": true, \"telemetry\": {\"metrics_prefix\":\"${var.product}.${var.environment}.consul.server\", \"statsd_address\":\"10.0.0.36:8125\"}}"
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
                "-retry-join",
                "provider=aws tag_key=ConsulCluster tag_value=${var.product}-${var.environment}",
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

resource "aws_security_group" "consul-server" {
  name = "consul-server-${var.product}-${var.environment}"

  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.admin_cidr}"]
  }

  tags {
    Name        = "consul-server-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "consul-client" {
  name = "consul-client-${var.product}-${var.environment}"

  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  tags {
    Name        = "consul-client-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
  }
}
