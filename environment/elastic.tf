resource "aws_ecs_service" "elasticsearch" {
  name            = "elasticsearch-${local.environment}"
  cluster         = "default-efs-${local.environment}"
  task_definition = "elasticsearch-${local.environment}:${aws_ecs_task_definition.elasticsearch.revision}"
  desired_count   = "${var.elasticsearch_task_status == "down" ? 0 : 1}"
}

resource "aws_ecs_task_definition" "elasticsearch" {
  family       = "elasticsearch-${local.environment}"
  network_mode = "bridge"

  volume {
    name      = "elasticsearch-data"
    host_path = "/opt/mount1/elasticsearch"
  }

  volume {
    name      = "consul_config"
    host_path = "/etc/consul"
  }

  volume {
    name      = "goss_config"
    host_path = "/goss/consul"
  }

  container_definitions = <<DEFINITION
    [
        {
            "name": "elasticsearch",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/elasticsearch:b42c851",
            "memory": 2000,
            "portMappings": [
                {
                  "hostPort": 9200,
                  "containerPort": 9200,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 9300,
                  "containerPort": 9300,
                  "protocol": "tcp"
                }
            ],
            "ulimits": [
                {
                "name": "nofile",
                "hardLimit": 65536,
                "softLimit": 65536
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "elasticsearch-data",
                  "containerPath": "/usr/share/elasticsearch/data",
                  "readOnly": false
                },
                {
                  "sourceVolume": "consul_config",
                  "containerPath": "/etc/consul",
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

resource "aws_security_group" "elasticsearch" {
  name = "elastic"

  description = "elasticsearch security group"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["${local.admin_cidr}"]
  }

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "elasticsearch-${local.product}-${local.environment}"
    Product     = "${local.product}"
    Environment = "${local.environment}"
    Layer       = "elasticsearch"
  }
}
