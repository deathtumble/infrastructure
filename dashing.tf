resource "aws_ebs_volume" "dashing" {
  availability_zone = "${var.availability_zone}"
  size              = 22

  tags {
    Name = "dashing"
  }
}

resource "aws_volume_attachment" "dashing" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.dashing.id}"
  instance_id  = "${aws_instance.dashing.id}"
  force_detach = true
  depends_on   = ["aws_ebs_volume.dashing", "aws_instance.dashing"]
}

resource "aws_instance" "dashing" {
  count                   = "1"
  ami                     = "${var.ecs_ami_id}"
  availability_zone       = "${var.availability_zone}"
  tenancy                 = "default"
  ebs_optimized           = "false"
  disable_api_termination = "false"
  instance_type           = "t2.small"
  key_name                = "${var.key_name}"
  private_ip              = "${var.dashing_ip}"
  monitoring              = "false"

  vpc_security_group_ids = [
    "${aws_security_group.dashing.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
  ]

  subnet_id                   = "${aws_subnet.dashing.id}"
  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#!/bin/bash
mkdir /opt/mount1
mount /dev/xvdh /opt/mount1
echo /dev/xvdh  /opt/mount1 ext4 defaults,nofail 0 2 >> /etc/fstab
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=dashing
EOF

  tags {
    Name        = "dashing"
    Product     = "${var.product}"
    Environment = "${var.environment}"
  }
}

resource "aws_ecs_cluster" "dashing" {
  name = "dashing"
}

resource "aws_ecs_service" "dashing" {
  name            = "dashing"
  cluster         = "dashing"
  task_definition = "dashing:${aws_ecs_task_definition.dashing.revision}"
  depends_on      = ["aws_ecs_cluster.dashing", "aws_instance.dashing"]
  desired_count   = 1
}

resource "aws_ecs_task_definition" "dashing" {
  family       = "dashing"
  network_mode = "host"

  volume {
    name      = "dashboards"
    host_path = "/opt/smashing/dashboards"
  }

  volume {
    name      = "assets"
    host_path = "/opt/smashing/assets"
  }

  volume {
    name      = "config"
    host_path = "/opt/smashing/config"
  }

  volume {
    name      = "public"
    host_path = "/opt/smashing/public"
  }

  volume {
    name      = "lib"
    host_path = "/opt/smashing/lib"
  }

  volume {
    name      = "jobs"
    host_path = "/opt/smashing/jobs"
  }

  volume {
    name      = "widgets"
    host_path = "/opt/smashing/widgets"
  }

  volume {
    name      = "consul_config"
    host_path = "/opt/consul/conf"
  }

  container_definitions = <<DEFINITION
	[
        {
            "name": "consul-agent",
            "cpu": 0,
            "essential": false,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/consul:0.1.0",
            "memory": 500,
            "environment": [
                {
                    "Name": "CONSUL_LOCAL_CONFIG",
                    "Value": "{\"leave_on_terminate\": true}"
                },
                {
                    "Name": "CONSUL_BIND_INTERFACE",
                    "Value": "eth0"
                }, 
                {
                    "Name": "CONSUL_CLIENT_INTERFACE",
                    "Value": "lo"
                }, 
                {
                    "Name": "CONSUL_ALLOW_PRIVILEGED_PORTS",
                    "Value": ""
                }
            ],
            "command": [
                "agent",
                "-dns-port=53",
                "-recursor=10.0.0.2",
                "-retry-join",
                "provider=aws tag_key=ConsulCluster tag_value=${var.product}-${var.environment}"
            ],
            "mountPoints": [
                {
                  "sourceVolume": "consul_config",
                  "containerPath": "/consul/config",
                  "readOnly": false
                }
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
        },
		{
			"name": "collectd",
			"cpu": 0,
			"dnsServers": ["127.0.0.1"],
		    "essential": false,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:0.1.1",
		    "memory": 500,
		    "environment": [
		    	{
		    		"Name": "GRAPHITE_HOST",
		    		"Value": "graphite.service.consul"
		    	}, 
		    	{
		    		"Name": "GRAPHITE_PREFIX",
		    		"Value": "${var.product}.${var.environment}.dashing."
		    	}
		    ]
		},
		{
			"name": "dashing",
			"cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/smashing:e9cbf47b9e36",
		    "memory": 500,
            "environment": [
                {
                    "Name": "PORT",
                    "Value": "8080"
                }
             ], 
		    "portMappings": [
		        {
		          "hostPort": 8080,
		          "containerPort": 8080,
		          "protocol": "tcp"
		        }
		    ],
		    "mountPoints": [
                {
                  "sourceVolume": "assets",
                  "containerPath": "/assets",
                  "readOnly": false
                },
                {
                  "sourceVolume": "dashboards",
                  "containerPath": "/dashboards",
                  "readOnly": false
                },
                {
                  "sourceVolume": "jobs",
                  "containerPath": "/jobs",
                  "readOnly": false
                },
                {
                  "sourceVolume": "lib",
                  "containerPath": "/lib-smashing",
                  "readOnly": false
                },
                {
                  "sourceVolume": "public",
                  "containerPath": "/public",
                  "readOnly": false
                },
                {
                  "sourceVolume": "widgets",
                  "containerPath": "/widgets",
                  "readOnly": false
                },
                {
                  "sourceVolume": "config",
                  "containerPath": "/config",
                  "readOnly": false
                }
            ]
		}
	]
    DEFINITION
}

resource "aws_lb_cookie_stickiness_policy" "dashing" {
  name                     = "dashing"
  load_balancer            = "${aws_elb.dashing.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_elb" "dashing" {
  name            = "dashing"
  security_groups = ["${aws_security_group.dashing.id}"]
  subnets         = ["${aws_subnet.dashing.id}"]
  depends_on      = ["aws_security_group.dashing"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/sample"
    interval            = 30
  }
}

resource "aws_route53_record" "dashing" {
  zone_id = "${var.aws_route53_zone_id}"
  name    = "dashing"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_elb.dashing.dns_name}"]
}

resource "aws_elb_attachment" "dashing" {
  count    = "1"
  elb      = "${aws_elb.dashing.id}"
  instance = "${aws_instance.dashing.id}"
}

resource "aws_route_table" "dashing" {
  vpc_id     = "${var.aws_vpc_id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name        = "dashing-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
    Layer       = "dashing"
  }
}

resource "aws_route" "dashing" {
  route_table_id         = "${aws_route_table.dashing.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"

  depends_on = ["aws_route_table.dashing", "aws_internet_gateway.default"]
}

resource "aws_subnet" "dashing" {
  vpc_id            = "${var.aws_vpc_id}"
  cidr_block        = "${var.dashing_subnet}"
  availability_zone = "${var.availability_zone}"
  depends_on        = ["aws_vpc.default"]

  tags {
    Name = "dashing-${var.product}-${var.environment}"
  }
}

resource "aws_route_table_association" "dashing" {
  subnet_id      = "${aws_subnet.dashing.id}"
  route_table_id = "${aws_route_table.dashing.id}"
  depends_on     = ["aws_route_table.dashing", "aws_subnet.dashing"]
}

resource "aws_security_group" "dashing" {
  name = "dashing"

  description = "dashing security group"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
