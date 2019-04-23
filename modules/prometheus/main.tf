variable "healthchecks" {
  type = list(map(string))
  default = [
    {
      healthy_threshold   = 2
      unhealthy_threshold = 10
      timeout             = 60
      path                = "/graph"
      protocol            = "HTTP"
      port                = "9090"
      interval            = 300
      matcher             = "200,401,302"
    },
  ]
}

module "prometheus-ecs-alb" {
  source = "../ecs-alb"

  healthchecks                    = var.healthchecks
  elb_instance_port               = "9090"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/graph"
  task_definition                 = "prometheus-${var.context.environment.name}:${aws_ecs_task_definition.prometheus.revision}"
  task_status                     = var.task_status
  aws_lb_listener_rule_priority   = 93
  aws_lb_listener_default_arn     = var.aws_lb_listener_default_arn
  aws_route53_environment_zone_id = var.aws_route53_environment_zone_id
  aws_alb_default_dns_name        = var.aws_alb_default_dns_name
  vpc_id                          = var.vpc_id
  product                         = var.context.product.name
  environment                     = var.context.environment.name
  root_domain_name                = var.context.product.root_domain_name
  ecs_iam_role                    = var.ecs_iam_role
  role                            = "prometheus"
  cluster_name                    = "default-efs"
}

resource "aws_ecs_task_definition" "prometheus" {
  family       = "prometheus-${var.context.environment.name}"
  network_mode = "host"

  volume {
    name      = "consul_config"
    host_path = "/etc/consul"
  }

  volume {
    name      = "goss_config"
    host_path = "/etc/goss"
  }

  volume {
    name      = "prometheus-data"
    host_path = "/opt/mount1/prometheus"
  }

  container_definitions = <<DEFINITION
    [
        {
            "name": "prometheus",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/prometheus:${var.docker_tag}",
            "memory": 2000,
            "dnsServers": ["127.0.0.1"],
            "environment": [
                {
                    "Name": "AWS_ACCESS_KEY_ID",
                    "Value": "${aws_iam_access_key.prometheus.id}"
                },
                {
                    "Name": "AWS_SECRET_ACCESS_KEY",
                    "Value": "${replace(aws_iam_access_key.prometheus.secret, "/", "\\/")}"
                },
                {
                    "Name": "ENVIRONMENT",
                    "Value": "${var.context.environment.name}"
                },
                {
                    "Name": "aws.region",
                    "Value": "${var.context.region.name}"
                }
             ], 
            "portMappings": [
                {
                  "hostPort": 9090,
                  "containerPort": 9090,
                  "protocol": "tcp"
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
                },
                {
                  "sourceVolume": "prometheus-data",
                  "containerPath": "/prometheus",
                  "readOnly": false
                }
            ]
        }
    ]
    
DEFINITION

}

resource "aws_security_group" "prometheus" {
  name = "prometheus"

  description = "prometheus security group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prometheus-${var.context.product.name}-${var.context.environment.name}"
    Product = var.context.product.name
    Environment = var.context.environment.name
    Layer = "prometheus"
  }
}

resource "aws_iam_user" "prometheus" {
  name = "prometheus-${var.context.product.name}-${var.context.environment.name}"
  path = "/"
}

resource "aws_iam_access_key" "prometheus" {
  user = aws_iam_user.prometheus.name
}

resource "aws_iam_user_policy" "prometheus" {
  name = "prometheus"

  user = aws_iam_user.prometheus.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
EOF

}

