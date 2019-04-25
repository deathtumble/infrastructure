module "nexus-ecs-alb" {
  source = "../ecs-alb"

  healthchecks                    = {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 3
      path                = "/service/metrics/healthcheck"
      protocol            = "HTTP"
      port                = "8081"
      interval            = 300
      matcher             = "200,401,302"
    }
  elb_instance_port               = "8081"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/service/metrics/healthcheck"
  task_definition                 = "nexus-${var.context.environment.name}:${aws_ecs_task_definition.nexus.revision}"
  task_status                     = var.task_status
  aws_lb_listener_rule_priority   = 95
  aws_lb_listener_default_arn     = var.aws_lb_listener_default_arn
  aws_route53_environment_zone_id = var.aws_route53_environment_zone_id
  aws_alb_default_dns_name        = var.aws_alb_default_dns_name
  vpc_id                          = var.vpc_id
  product                         = var.context.product.name
  environment                     = var.context.environment.name
  root_domain_name                = var.context.product.root_domain_name
  ecs_iam_role                    = var.ecs_iam_role
  role                            = "nexus"
  cluster_name                    = "default-efs"
}

resource "aws_ecs_task_definition" "nexus" {
  family       = "nexus-${var.context.environment.name}"
  network_mode = "bridge"

  volume {
    name      = "nexus-data"
    host_path = "/opt/mount1/nexus"
  }

  volume {
    name      = "consul_config"
    host_path = "/etc/consul"
  }

  container_definitions = <<DEFINITION
    [
        {
            "name": "nexus",
            "cpu": 0,
            "essential": true,
            "image": "sonatype/nexus3:3.10.0",
            "memory": 2000,
            "portMappings": [
                {
                  "hostPort": 8081,
                  "containerPort": 8081,
                  "protocol": "tcp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "nexus-data",
                  "containerPath": "/nexus-data",
                  "readOnly": false
                }
            ]
        }
    ]
    
DEFINITION

}

resource "aws_security_group" "nexus" {
  name = "nexus"

  description = "nexus security group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8081
    to_port = 8081
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
    Name = "nexus-${var.context.product.name}-${var.context.environment.name}"
    Product = var.context.product.name
    Environment = var.context.environment.name
    Layer = "nexus"
  }
}

