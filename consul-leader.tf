resource "aws_instance" "consul-leader" {
  count                   = "1"
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
ECS_CLUSTER=consul-leader
HOSTNAME=consul-${var.product}-${var.environment}-leader
EOF

  tags {
    Name          = "consul-0"
    Product       = "${var.product}"
    Environment   = "${var.environment}"
    ConsulCluster = "${var.product}-${var.environment}"
  }
}

resource "aws_elb_attachment" "consul-leader" {
  elb      = "${aws_elb.consului.id}"
  instance = "${aws_instance.consul-leader.id}"
}

resource "aws_ecs_cluster" "consul-leader" {
  name = "consul-leader"
}

resource "aws_ecs_service" "consul-leader" {
  name            = "consul-leader"
  cluster         = "consul-leader"
  task_definition = "consul-leader:${aws_ecs_task_definition.consul-leader.revision}"
  depends_on      = ["aws_ecs_cluster.consul-leader", "aws_ecs_task_definition.consul-leader"]
  desired_count   = 1
}

resource "aws_ecs_task_definition" "consul-leader" {
  family       = "consul-leader"
  network_mode = "host"

  container_definitions = <<DEFINITION
    [
        {
            "name": "collectd",
            "cpu": 0,
            "essential": false,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:${var.collectd_docker_tag}",
            "memory": 500,
            "environment": [
                {
                    "Name": "HOST_NAME",
                    "Value": "consul-leader"
                },
                {
                    "Name": "GRAPHITE_HOST",
                    "Value": "10.0.0.36"
                }, 
                {
                    "Name": "GRAPHITE_PREFIX",
                    "Value": "${var.product}.${var.environment}.consul."
                }
            ]
        },
        {
            "name": "consul-leader",
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
                "-bootstrap",
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

