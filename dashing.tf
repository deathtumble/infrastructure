variable "dashing_subnet" {
  type    = "string"
  default = "10.0.0.144/28"
}

module "dashing" {
  source = "./role"

  role = "dashing"

  vpc_security_group_ids = [
    "${aws_security_group.dashing.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
  ]

  elb_security_group   = "${aws_security_group.dashing.id}"
  elb_instance_port    = "80"
  elb_port             = "80"
  healthcheck_port     = "80"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/sample"
  task_definition      = "dashing:${aws_ecs_task_definition.dashing.revision}"
  desired_count        = "1"

  volume_id = ""

  // todo remove need to specify    
  cidr_block = "${var.dashing_subnet}"

  // globals
  key_name                   = "${var.key_name}"
  vpc_id                     = "${aws_vpc.default.id}"
  gateway_id                 = "${aws_internet_gateway.default.id}"
  availability_zone          = "${var.availability_zone}"
  ami_id                     = "${var.ecs_ami_id}"
  product                    = "${var.product}"
  environment                = "${var.environment}"
  aws_route53_record_zone_id = "${var.aws_route53_zone_id}"
}

data "template_file" "collectd-dashing" {
  template = "${file("files/collectd.tpl")}"

  vars {
    graphite_prefix = "${var.product}.${var.environment}.dashing."
  }
}

resource "aws_ecs_task_definition" "dashing" {
  family       = "dashing"
  network_mode = "host"

  volume {
    name      = "consul_config"
    host_path = "/opt/consul/conf"
  }

  container_definitions = <<DEFINITION
    [
        ${data.template_file.consul_agent.rendered},
        ${data.template_file.collectd-dashing.rendered},
        {
            "name": "dashing",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/smashing:latest",
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
            ]
        },
        {
            "name": "aws-proxy",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/aws_proxy:0.1.0-SNAPSHOT",
            "memory": 200,
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
