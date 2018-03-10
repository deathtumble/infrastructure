module "concourse" {
  source = "./role"

  role = "concourse"

  vpc_security_group_ids = [
    "${aws_security_group.concourse.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
  ]

  elb_security_group   = "${aws_security_group.concourse.id}"
  elb_instance_port    = "8080"
  elb_port             = "80"
  healthcheck_port     = "8080"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/"
  task_definition      = "concourse:${aws_ecs_task_definition.concourse.revision}"
  desired_count        = "1"
  instance_type        = "t2.medium"

  volume_id = "vol-0cc66dcb2a5b637d2"

  // todo remove need to specify    
  cidr_block = "${var.concourse_subnet}"
  private_ip = "${var.concourse_ip}"

  // globals
  vpc_id                     = "${var.aws_vpc_id}"
  gateway_id                 = "${aws_internet_gateway.default.id}"
  availability_zone          = "${var.availability_zone}"
  ami_id                     = "${var.ecs_ami_id}"
  product                  = "${var.product}"
  environment                = "${var.environment}"
  aws_route53_record_zone_id = "${aws_route53_zone.root.zone_id}"
}

data "template_file" "collectd-concourse" {
  template = "${file("files/collectd.tpl")}"

  vars {
    graphite_prefix = "${var.product}.${var.environment}.concourse."
  }
}

resource "aws_ecs_task_definition" "concourse" {
  family       = "concourse"
  network_mode = "host"

  volume {
    name      = "postgres_data"
    host_path = "/opt/mount1/database"
  }

  volume {
    name      = "concourse_web_keys"
    host_path = "/opt/mount1/keys/web"
  }

  volume {
    name      = "concourse_worker_keys"
    host_path = "/opt/mount1/keys/worker"
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
            "name": "concourse-db",
            "cpu": 0,
            "essential": true,
            "image": "postgres:9.6",
            "memory": 490,
            "environment": [
                {
                    "Name": "POSTGRES_DB",
                    "Value": "concourse"
                }, 
                {
                    "Name": "POSTGRES_USER",
                    "Value": "concourse"
                }, 
                {
                    "Name": "POSTGRES_PASSWORD",
                    "Value": "${var.concourse_postgres_password}"
                }, 
                {
                    "Name": "PGDATA",
                    "Value": "/database"
                }
            ],
            "mountPoints": [
                {
                    "sourceVolume": "postgres_data",
                    "containerPath": "/database",
                    "readOnly": false
                }
            ],
            "portMappings": [
                {
                  "hostPort": 5432,
                  "containerPort": 5432,
                  "protocol": "tcp"
                }
            ]
        },
        {
            "name": "concourse-web",
            "cpu": 0,
            "essential": true,
            "image": "concourse/concourse",
            "command": ["web"],
            "memory": 500,
            "portMappings": [
                {
                  "hostPort": 8080,
                  "containerPort": 8080,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 2222,
                  "containerPort": 2222,
                  "protocol": "tcp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "concourse_web_keys",
                  "containerPath": "/concourse-keys",
                  "readOnly": false
                }
            ],
            "environment": [
                {
                    "Name": "CONCOURSE_BASIC_AUTH_USERNAME",
                    "Value": "concourse"
                }, 
                {
                    "Name": "CONCOURSE_BASIC_AUTH_PASSWORD",
                    "Value": "${var.concourse_password}"
                }, 
                {
                    "Name": "CONCOURSE_EXTERNAL_URL",
                    "Value": "http://concourse.${var.root_domain_name}"
                }, 
                {
                    "Name": "CONCOURSE_POSTGRES_HOST",
                    "Value": "172.17.0.1"
                }, 
                {
                    "Name": "CONCOURSE_POSTGRES_USER",
                    "Value": "concourse"
                }, 
                {
                    "Name": "CONCOURSE_POSTGRES_PASSWORD",
                    "Value": "${var.concourse_postgres_password}"
                }, 
                {
                    "Name": "CONCOURSE_POSTGRES_DATABASE",
                    "Value": "concourse"
                }
            ]
        },
        {
            "name": "concourse-worker",
            "cpu": 0,
            "essential": false,
            "privileged": true,
            "image": "concourse/concourse",
            "command": ["worker"],
            "memory": 500,
            "mountPoints": [
                {
                  "sourceVolume": "concourse_worker_keys",
                  "containerPath": "/concourse-keys",
                  "readOnly": false
                }
            ],
            "environment": [
                {
                    "Name": "CONCOURSE_TSA_HOST",
                    "Value": "172.17.0.1"
                }
            ]
         } 
    ]
    DEFINITION
}

resource "aws_security_group" "concourse" {
  name = "concourse"

  description = "concourse security group"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.admin_cidrs}"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "${var.vpc_cidr}"]
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
    Name        = "concourse-${var.product}-${var.environment}"
    Product   = "${var.product}"
    Environment = "${var.environment}"
    Layer       = "concourse"
  }
}
