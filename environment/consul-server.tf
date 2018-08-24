resource "aws_instance" "consul" {
  count                   = "${var.consul_server_count}"
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
    "${aws_security_group.cadvisor.id}",
    "${aws_security_group.consul.id}",
  ]

  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#cloud-config
write_files:
 - content: ECS_CLUSTER=consul-${local.environment}
   path: /etc/ecs/ecs.config   
   permissions: '0644'
runcmd:
 - service goss start
 - service modd start
 - service cadvisor start
 - service node_exporter start
EOF
  
  tags {
    Name          = "consul-${lookup(var.consul_server_instance_names, count.index)}"
    Product       = "${local.product}"
    Environment   = "${local.environment}"
    ConsulCluster = "${local.product}-${local.environment}"
    Goss          = "true"
  }
}

module "consul-ecs-alb" {
  source = "../ecs-alb"

  elb_instance_port    = "8500"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/v1/agent/checks"
  task_definition      = "consul-${local.environment}:${aws_ecs_task_definition.consul.revision}"
  task_status          = "${var.consul_task_status}"
  desired_task_count   = "3"
  aws_lb_listener_default_arn = "${aws_alb_listener.default.arn}"
  aws_lb_listener_rule_priority = 94
  aws_route53_environment_zone_id      = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name = "${aws_alb.default.dns_name}"
  vpc_id                   = "${aws_vpc.default.id}"
  role = "consul"
  product = "${local.product}"
  environment = "${local.environment}"
  root_domain_name = "${local.root_domain_name}"
}

data "template_file" "collectd-consul" {
  template = "${file("${path.module}/files/collectd.tpl")}"

  vars {
    graphite_prefix = "${local.product}.${local.environment}.consul."
    collectd_docker_tag = "${var.collectd_docker_tag}"
  }
}

resource "aws_ecs_task_definition" "consul" {
  family       = "consul-${local.environment}"
  network_mode = "bridge"

  container_definitions = <<DEFINITION
    [
        {
            "name": "consul",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/consul:${var.consul_docker_tag}",
            "memory": 500,
            "environment": [
                {
                    "Name": "CONSUL_LOCAL_CONFIG",
                    "Value": "{\"skip_leave_on_interrupt\": true, \"telemetry\": {\"metrics_prefix\":\"${local.product}.${local.environment}.consul.server\"}}"
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
                "-bootstrap-expect=3",
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

resource "aws_security_group" "consul" {
  name = "consul-${local.product}-${local.environment}"

  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${local.admin_cidr}", "${var.vpc_cidr}"]
  }

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
    cidr_blocks = ["${var.vpc_cidr}", "${local.admin_cidr}"]
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
    cidr_blocks = ["${var.vpc_cidr}", "${local.admin_cidr}"]
  }

  tags {
    Name        = "consul-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
  }
}

resource "aws_security_group" "consul-client" {
  name = "consul-client-${local.product}-${local.environment}"

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
    Name        = "consul-client-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
  }
}
