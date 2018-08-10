resource "aws_instance" "consul-leader" {
  count                   = "1"
  ami                     = "${var.ecs_ami_id}"
  availability_zone       = "${var.availability_zone_1}"
  tenancy                 = "default"
  ebs_optimized           = "false"
  disable_api_termination = "false"
  instance_type           = "t2.small"
  key_name                = "${local.key_name}"
  monitoring              = "false"

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul.id}",
  ]

  subnet_id                   = "${aws_subnet.av1.id}"
  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#cloud-config
write_files:
 - content: ECS_CLUSTER=consul-leader-${local.environment}
   path: /etc/ecs/ecs.config   
   permissions: '0644'
runcmd:
 - service goss start
 - service modd start
EOF

  tags {
    Name          = "consul-0"
    Product       = "${local.product}"
    Environment   = "${local.environment}"
    ConsulCluster = "${local.product}-${local.environment}"
    Goss          = "true"
  }
}

resource "aws_ecs_cluster" "consul-leader" {
  name = "consul-leader-${local.environment}"
}

resource "aws_ecs_service" "consul-leader" {
  name            = "consul-leader-${local.environment}"
  cluster         = "consul-leader-${local.environment}"
  task_definition = "consul-leader-${local.environment}:${aws_ecs_task_definition.consul-leader.revision}"
  depends_on      = ["aws_ecs_cluster.consul-leader", "aws_ecs_task_definition.consul-leader"]
  desired_count   = 1
}

data "template_file" "collectd-consul-leader" {
  template = "${file("${path.module}/files/collectd.tpl")}"

  vars {
    graphite_prefix = "${local.product}.${local.environment}.consul."
    collectd_docker_tag = "${var.collectd_docker_tag}"
  }
}

resource "aws_ecs_task_definition" "consul-leader" {
  family       = "consul-leader-${local.environment}"
  network_mode = "host"

  container_definitions = <<DEFINITION
    [
        ${data.template_file.collectd-consul-leader.rendered},
        {
            "name": "consul-leader",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/consul:${var.consul_docker_tag}",
            "memory": 500,
            "environment": [
                {
                    "Name": "CONSUL_LOCAL_CONFIG",
                    "Value": "{\"skip_leave_on_interrupt\": true, \"telemetry\": {\"metrics_prefix\":\"${local.product}.${local.environment}.consul.server\", \"statsd_address\":\"10.0.0.36:8125\"}}"
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

