module "consul-ecs-alb" {
  source = "../ecs-alb"

  healthchecks = {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 3
      path                = "/v1/agent/checks"
      protocol            = "HTTP"
      port                = "8500"
      interval            = 5
      matcher             = "200,401,302"
    }
    
  elb_instance_port               = "8500"
  healthcheck_protocol            = "HTTP"
  healthcheck_path                = "/v1/agent/checks"
  task_definition                 = "consul-${var.context.environment.name}:${aws_ecs_task_definition.consul.revision}"
  task_status                     = var.task_status
  desired_task_count              = "3"
  aws_lb_listener_rule_priority   = 94
  
  aws_lb_listener_default_arn     = var.aws_lb_listener_default_arn
  aws_route53_environment_zone_id = var.aws_route53_environment_zone_id
  aws_alb_default_dns_name        = var.aws_alb_default_dns_name
  vpc_id                          = var.vpc_id

  product                         = var.context.product.name
  environment                     = var.context.environment.name
  root_domain_name                = var.context.product.root_domain_name
  ecs_iam_role                    = var.ecs_iam_role
  role                            = "consul"
  cluster_name                    = "consul"
}

resource "aws_ecs_cluster" "consul" {
  name = "consul-${var.context.environment.name}"
}

resource "aws_ecs_task_definition" "consul" {
  family       = "consul-${var.context.environment.name}"
  network_mode = "host"

  container_definitions = <<DEFINITION
    [
        {
            "name": "consul",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/consul:${var.docker_tag}",
            "memory": 500,
            "privileged": true,
            "environment": [
                {
                    "Name": "CONSUL_LOCAL_CONFIG",
                    "Value": "{\"skip_leave_on_interrupt\": true, \"telemetry\": {\"metrics_prefix\":\"${var.context.product.name}.${var.context.environment.name}.consul.server\"}}"
                },
                {
                    "Name": "CONSUL_BIND_INTERFACE",
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
                "-recursor=${var.vpc.dns_ip}",
                "-bootstrap-expect=3",
                "-client=0.0.0.0",
                "-retry-join",
                "provider=aws tag_key=ConsulCluster tag_value=${var.context.product.name}-${var.context.environment.name}",
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
  name = "consul-${var.context.product.name}-${var.context.environment.name}"

  vpc_id = var.vpc_id

  ingress {
    from_port = 8082
    to_port = 8082
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8300
    to_port = 8300
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8302
    to_port = 8302
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8302
    to_port = 8302
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "consul-${var.context.product.name}-${var.context.environment.name}"
    Product = var.context.product.name
    Environment = var.context.environment.name
  }
}

