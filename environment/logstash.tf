resource "aws_ecs_service" "logstash" {
  name            = "logstash-${var.context.environment.name}"
  cluster         = "default-efs-${var.context.environment.name}"
  task_definition = "logstash-${var.context.environment.name}:${aws_ecs_task_definition.logstash.revision}"
  desired_count   = var.logstash_task_status == "down" ? 0 : 1
}

resource "aws_ecs_task_definition" "logstash" {
  family       = "logstash-${var.context.environment.name}"
  network_mode = "host"

  volume {
    name      = "consul_config"
    host_path = "/etc/consul"
  }

  volume {
    name      = "goss_config"
    host_path = "/etc/goss"
  }

  container_definitions = <<DEFINITION
    [
        {
            "name": "logstash",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/logstash:${var.logstash_docker_tag}",
            "memory": 2000,
            "portMappings": [
                {
                  "hostPort": 9600,
                  "containerPort": 9600,
                  "protocol": "tcp"
                },
                {
                  "hostPort": 5044,
                  "containerPort": 5044,
                  "protocol": "tcp"
                }
            ],
            "environment": [
                {
                    "Name": "ELASTICSEARCH_URL",
                    "Value": "http://elasticsearch.service.consul:9200"
                }
             ], 
            "mountPoints": [
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

resource "aws_security_group" "logstash" {
  name = "logstash"

  description = "logstash security group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 9600
    to_port = 9600
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5044
    to_port = 5044
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "logstash-${var.context.product.name}-${var.context.environment.name}"
    Product = var.context.product.name
    Environment = var.context.environment.name
    Layer = "logstash"
  }
}

