resource "aws_ecs_service" "aws-proxy" {
  name            = "aws_proxy-${var.context.environment.name}"
  cluster         = "default-${var.context.environment.name}"
  task_definition = "aws-proxy-${var.context.environment.name}:${aws_ecs_task_definition.aws-proxy.revision}"
  desired_count   = var.task_status == "down" ? 0 : 1
}

resource "aws_ecs_task_definition" "aws-proxy" {
  family       = "aws-proxy-${var.context.environment.name}"
  network_mode = "bridge"

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
            "name": "aws-proxy",
            "cpu": 0,
            "essential": true,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/aws-proxy:${var.docker_tag}",
            "memory": 2000,
            "environment": [
                {
                    "Name": "AWS_ACCESS_KEY_ID",
                    "Value": "${aws_iam_access_key.aws_proxy.id}"
                },
                {
                    "Name": "AWS_SECRET_ACCESS_KEY",
                    "Value": "${aws_iam_access_key.aws_proxy.secret}"
                },
                {
                    "Name": "aws.region",
                    "Value": "${var.context.region.name}"
                }
             ], 
            "portMappings": [
                {
                  "hostPort": 8081,
                  "containerPort": 8081,
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
                }
            ]
        }
    ]
    
DEFINITION

}

resource "aws_security_group" "aws-proxy" {
  name = "aws-proxy"

  description = "aws-proxy security group"
  vpc_id = var.vpc_id

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
    Name = "aws-proxy-${var.context.product.name}-${var.context.environment.name}"
    Product = var.context.product.name
    Environment = var.context.environment.name
    Layer = "aws-proxy"
  }
}

resource "aws_iam_user" "aws_proxy" {
  name = "aws-proxy-${var.context.product.name}-${var.context.environment.name}"
  path = "/"
}

resource "aws_iam_access_key" "aws_proxy" {
  user = aws_iam_user.aws_proxy.name
}

resource "aws_iam_user_policy" "aws_proxy" {
  name = "aws_proxy"

  user = aws_iam_user.aws_proxy.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ecs:ListClusters",
                "ecs:ListServices",
                "ecs:DescribeServices",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetHealth"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetHealth"
            ],
            "Resource": "arn:aws:elasticloadbalancing:eu-west-1:453254632971:loadbalancer/app/*"
        }
    ]
}
EOF

}

