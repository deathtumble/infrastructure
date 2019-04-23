variable "healthchecks" {
  type = list(map(string))
  default = [
    {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 3
      path                = "/api/health"
      protocol            = "HTTP"
      port                = "3000"
      interval            = 5
      matcher             = "200,401,302"
    },
  ]
}

module "grafana-ecs-alb" {
  source = "../ecs-alb"

  healthchecks                    = var.healthchecks
  elb_instance_port               = "3000"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/api/health"
  task_definition                 = "grafana-${var.context.environment.name}:${aws_ecs_task_definition.grafana.revision}"
  task_status                     = var.task_status
  aws_lb_listener_rule_priority   = 96
  aws_lb_listener_default_arn     = var.aws_lb_listener_default_arn
  aws_route53_environment_zone_id = var.aws_route53_environment_zone_id
  aws_alb_default_dns_name        = var.aws_alb_default_dns_name
  vpc_id                          = var.vpc_id
  product                         = var.context.product.name
  environment                     = var.context.environment.name
  root_domain_name                = var.context.product.root_domain_name
  ecs_iam_role                    = var.ecs_iam_role
  role                            = "grafana"
  cluster_name                    = "default-efs"
}

resource "aws_ecs_task_definition" "grafana" {
  family       = "grafana-${var.context.environment.name}"
  network_mode = "host"

  volume {
    name      = "consul_config"
    host_path = "/etc/consul"
  }

  volume {
    name      = "grafana_data"
    host_path = "/opt/mount1/grafana"
  }

  volume {
    name      = "grafana_plugins"
    host_path = "/opt/mount1/grafana/plugins"
  }

  volume {
    name      = "grafana_logs"
    host_path = "/opt/mount1/grafana_logs"
  }

  container_definitions = <<DEFINITION
    [
        {
            "name": "grafana",
            "cpu": 0,
            "essential": true,
            "image": "grafana/grafana:${var.docker_tag}",
            "memory": 500,
            "dnsServers": ["127.0.0.1"],
            "portMappings": [
                {
                  "hostPort": 3000,
                  "containerPort": 3000,
                  "protocol": "udp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "grafana_data",
                  "containerPath": "/var/lib/grafana/",
                  "readOnly": false
                },
                {
                  "sourceVolume": "grafana_plugins",
                  "containerPath": "/var/lib/grafana/plugins",
                  "readOnly": false
                },
                {
                  "sourceVolume": "grafana_logs",
                  "containerPath": "/var/log/grafana",
                  "readOnly": false
                }
            ]
        }
    ]
    
DEFINITION

}

resource "aws_security_group" "grafana" {
  name = "grafana"

  description = "grafana security group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 3000
    to_port = 3000
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
    Name = "grafana-${var.context.product.name}-${var.context.environment.name}"
    Product = var.context.product.name
    Environment = var.context.environment.name
    Layer = "grafana"
  }
}

