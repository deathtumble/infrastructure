variable "healthchecks" {
  type = list(map(string))
  default = [
    {
      healthy_threshold   = "10"
      unhealthy_threshold = "2"
      timeout             = "60"
      path                = "/status"
      protocol            = "HTTP"
      port                = "5601"
      interval            = "300"
      matcher             = "200,401,302"
    },
  ]
}

module "kibana-ecs-alb" {
  source = "../modules/ecs-alb"

  healthchecks                    = var.healthchecks
  elb_instance_port               = "5601"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/status"
  task_definition                 = "kibana-${var.context.environment.name}:${aws_ecs_task_definition.kibana.revision}"
  task_status                     = var.kibana_task_status
  aws_lb_listener_rule_priority   = 90
  aws_lb_listener_default_arn     = module.vpc.aws_lb_listener_default_arn
  aws_route53_environment_zone_id = module.vpc.aws_route53_environment_zone_id
  aws_alb_default_dns_name        = module.vpc.aws_alb_default_dns_name
  vpc_id                          = module.vpc.vpc_id
  product                         = var.context.product.name
  environment                     = var.context.environment.name
  root_domain_name                = var.context.product.root_domain_name
  ecs_iam_role                    = var.ecs_iam_role
  role                            = "kibana"
  cluster_name                    = "default-efs"
}

resource "aws_ecs_task_definition" "kibana" {
  family       = "kibana-${var.context.environment.name}"
  network_mode = "host"

  volume {
    name      = "kibana-data"
    host_path = "/opt/mount1/kibana"
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
            "name": "kibana",
            "cpu": 0,
            "essential": true,
            "image": "docker.elastic.co/kibana/kibana:6.4.0",
            "memory": 2000,
            "dnsServers": ["127.0.0.1"],
            "portMappings": [
                {
                  "hostPort": 5601,
                  "containerPort": 5601,
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
            "environment": [
                {
                    "Name": "SERVER_NAME",
                    "Value": "kibana.${module.vpc.aws_alb_default_dns_name}"
                },
                {
                    "Name": "ELASTICSEARCH_URL",
                    "Value": "http://elasticsearch.service.consul:9200"
                },
                {
                    "Name": "XPACK_MONITORING_ENABLED",
                    "Value": "false"
                }
             ], 
            "mountPoints": [
                {
                  "sourceVolume": "kibana-data",
                  "containerPath": "/usr/share/kibana/data",
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

resource "aws_security_group" "kibana" {
  name = "kibana"

  description = "kibana security group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 5601
    to_port = 5601
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
    Name = "kibana-${var.context.product.name}-${var.context.environment.name}"
    Product = var.context.product.name
    Environment = var.context.environment.name
    Layer = "kibana"
  }
}

