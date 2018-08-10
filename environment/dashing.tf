module "dashing" {
  source = "../role"

  role = "dashing"

  vpc_security_group_ids = [
    "${aws_security_group.dashing.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
  ]

  elb_instance_port    = "80"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/favicon.ico"
  task_definition      = "dashing-${var.environment}:${aws_ecs_task_definition.dashing.revision}"
  task_status          = "${var.dashing_task_status}"
  instance_type        = "t2.medium"

  volume_id = ""

  // globals
  aws_lb_listener_default_arn = "${aws_alb_listener.default.arn}"
  aws_lb_listener_rule_priority = 97
  key_name                 = "${var.key_name}"
  aws_subnet_id            = "${aws_subnet.av1.id}"
  vpc_id                   = "${aws_vpc.default.id}"
  gateway_id               = "${aws_internet_gateway.default.id}"
  availability_zone        = "${var.availability_zone_1}"
  ami_id                   = "${var.ecs_ami_id}"
  product                  = "${var.product}"
  environment              = "${var.environment}"
  aws_route53_zone_id      = "${aws_route53_zone.environment.zone_id}"
  aws_alb_default_dns_name = "${aws_alb.default.dns_name}"
  root_domain_name         = "${var.root_domain_name}"
}

data "template_file" "collectd-dashing" {
  template = "${file("${path.module}/files/collectd.tpl")}"

  vars {
    graphite_prefix = "${var.product}.${var.environment}.dashing."
    collectd_docker_tag = "${var.collectd_docker_tag}"
  }
}

resource "aws_ecs_task_definition" "dashing" {
  family       = "dashing-${var.environment}"
  network_mode = "host"

  volume {
    name      = "consul_config"
    host_path = "/opt/consul/conf"
  }

  volume {
    name      = "goss_config"
    host_path = "/etc/goss"
  }

  container_definitions = <<DEFINITION
    [
        ${data.template_file.consul_agent.rendered},
        ${data.template_file.collectd-dashing.rendered},
        {
            "name": "dashing",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/smashing:${var.dashing_docker_tag}",
            "memory": 200,
            "environment": [
                {
                    "Name": "PORT",
                    "Value": "80"
                }
             ], 
            "portMappings": [
                {
                  "hostPort": 80,
                  "containerPort": 80,
                  "protocol": "tcp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "consul_config",
                  "containerPath": "/opt/consul/conf",
                  "readOnly": false
                },
                {
                  "sourceVolume": "goss_config",
                  "containerPath": "/etc/goss",
                  "readOnly": false
                }
            ]
        },
        {
            "name": "aws-proxy",
            "cpu": 0,
            "essential": false,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/aws-proxy:${var.aws_proxy_docker_tag}",
            "memory": 500,
            "environment": [
                {
                    "Name": "AWS_ACCESS_KEY_ID",
                    "Value": "${var.aws-proxy_access_id}"
                },
                {
                    "Name": "AWS_SECRET_ACCESS_KEY",
                    "Value": "${var.aws-proxy_secret_access_key}"
                },
                {
                    "Name": "aws.region",
                    "Value": "${var.region}"
                }
             ], 
            "portMappings": [
                {
                  "hostPort": 8080,
                  "containerPort": 8080,
                  "protocol": "tcp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "consul_config",
                  "containerPath": "/opt/consul/conf",
                  "readOnly": false
                },
                {
                  "sourceVolume": "goss_config",
                  "containerPath": "/etc/goss",
                  "readOnly": false
                }
            ]
        }
    ]
    DEFINITION
}

resource "aws_security_group" "dashing" {
  name = "dashing"

  description = "dashing security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "dashing-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
    Layer       = "dashing"
  }
}
