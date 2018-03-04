module "nexus" {
    source = "./role"
        
    role = "nexus"
    private_ip = "${var.nexus_ip}"
    aws_security_group_id = "${aws_security_group.nexus.id}"
    aws_subnet_id = "${aws_subnet.nexus.id}" 
    
    availability_zone = "${var.availability_zone}"
    ami_id = "ami-567b1a2f"
    
    ecosystem = "${var.ecosystem}"
    environment = "${var.environment}"
    aws_security_group_ssh_id = "${aws_security_group.ssh.id}"
    aws_security_group_consul-client_id = "${aws_security_group.consul-client.id}"
    
    volume_id = "vol-0c80683f4a8142d69"
}

resource "aws_ecs_cluster" "nexus" {
  name = "nexus"
}

resource "aws_ecs_service" "nexus" {
  name            = "nexus"
  cluster         = "nexus"
  task_definition = "nexus:${aws_ecs_task_definition.nexus.revision}"
  desired_count   = 1
}

resource "aws_ecs_task_definition" "nexus" {
  family = "nexus"
  network_mode = "host"
  volume {
			name = "nexus-data"
			host_path = "/opt/mount1/nexus"
		}
  volume {
            name = "consul_config"
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
                "provider=aws tag_key=ConsulCluster tag_value=${var.nameTag}"
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
		    		"Value": "${var.ecosystem}.${var.environment}.nexus."
		    	}
		    ]
		},
		{
			"name": "nexus",
			"cpu": 0,
		    "essential": true,
		    "image": "sonatype/nexus:oss",
		    "memory": 500,
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
                  "containerPath": "/sonatype-work",
                  "readOnly": false
                }
            ]
		}
	]
    DEFINITION
}

resource "aws_lb_cookie_stickiness_policy" "nexus" {
  name                     = "nexus"
  load_balancer            = "${aws_elb.nexus.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_elb" "nexus" {
  name            = "nexus"
  security_groups = ["${aws_security_group.nexus.id}"]
  subnets = ["${aws_subnet.nexus.id}"]
  depends_on = ["aws_security_group.nexus"]
  
  listener {
    instance_port      = 8081
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }  

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8081/nexus/service/local/status"
    interval            = 5
  }
}

resource "aws_route53_record" "nexus" {
	zone_id = "${aws_route53_zone.root.zone_id}"
	name    = "nexus"
    type    = "CNAME"
    ttl     = 300
    records = ["${aws_elb.nexus.dns_name}"]
    depends_on = ["aws_route53_zone.root", "aws_elb.nexus"]
}

resource "aws_elb_attachment" "nexus" {
  count = "1" 
  elb      = "${aws_elb.nexus.id}"
  instance = "${module.nexus.instance_id}"
}

resource "aws_route_table" "nexus" {
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name = "nexus-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "nexus"
  }
}

resource "aws_route" "nexus" {
  route_table_id = "${aws_route_table.nexus.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
  
  depends_on = ["aws_route_table.nexus", "aws_internet_gateway.default"]
}

resource "aws_subnet" "nexus" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.nexus_subnet}"
  availability_zone = "${var.availability_zone}"
  depends_on      = ["aws_vpc.default"]

  tags {
    Name = "nexus-${var.nameTag}"
  }
}

resource "aws_route_table_association" "nexus" {
  subnet_id      = "${aws_subnet.nexus.id}"
  route_table_id = "${aws_route_table.nexus.id}"
  depends_on = ["aws_route_table.nexus", "aws_subnet.nexus"]
}

resource "aws_security_group" "nexus" {
  name        = "nexus"
  
  description = "nexus security group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}","${var.ecosystem_cidr}"]
  }
  
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}","${var.ecosystem_cidr}"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "nexus-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "nexus"
  }
}
