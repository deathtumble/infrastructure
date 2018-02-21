resource "aws_ebs_volume" "monitoring" {
	availability_zone = "${var.availability_zone}"
    size = 22
    tags {
        Name = "monitoring"
    }
}

resource "aws_volume_attachment" "monitoring" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.monitoring.id}"
  instance_id = "${aws_instance.graphite.id}"
  force_detach = true
  depends_on      = ["aws_ebs_volume.monitoring", "aws_instance.graphite"]
}

resource "aws_instance" "graphite" {
	count = "1"
	ami = "${var.ecs_ami_id}"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.medium"
    key_name = "poc"
    private_ip = "10.0.0.36"
    monitoring = "false",
    vpc_security_group_ids = [
    	"${aws_security_group.graphite.id}",
    	"${aws_security_group.ssh.id}",
    	"${aws_security_group.consul-client.id}"
    ],
    subnet_id = "${aws_subnet.monitoring.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
    depends_on      = ["aws_security_group.graphite", "aws_security_group.ssh", "aws_security_group.consul-client", "aws_subnet.consul"]
    user_data = <<EOF
#cloud-config
hostname: monitoring
write_files:
 - content: ECS_CLUSTER=graphite
   path: /etc/ecs/ecs.config   
   permissions: 644
 - content: ${base64encode(file("files/monitoring_consul.json"))}
   path: /opt/consul/conf/monitoring_consul.json
   encoding: b64
   permissions: 644
 - content: ${base64encode(file("files/monitoring_goss.yml"))}
   path: /etc/goss/goss.yaml
   encoding: b64
   permissions: 644
runcmd:
 - mkdir /opt/mount1
 - sleep 18
 - sudo mount /dev/xvdh /opt/mount1
 - sudo echo /dev/xvdh  /opt/mount1 ext4 defaults,nofail 0 2 >> /etc/fstab
 - chmod 644 /opt/consul/conf/monitoring_consul.json
 - sudo mount -a
 - service goss start
EOF

  tags {
    Name = "graphite"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	ConsulCluster = "${var.nameTag}"
	Goss = "true"
  }
}

resource "aws_ecs_cluster" "graphite" {
  name = "graphite"
}

resource "aws_ecs_service" "graphite" {
  name            = "graphite"
  cluster         = "graphite"
  task_definition = "graphite:${aws_ecs_task_definition.graphite.revision}"
  depends_on = ["aws_ecs_cluster.graphite", "aws_ecs_task_definition.graphite"]
  desired_count   = 1
}

resource "aws_ecs_task_definition" "graphite" {
  family = "graphite"
  network_mode = "host"
  volume {
			name = "consul_config"
			host_path = "/opt/consul/conf"
		}
  volume {
			name = "grafana_data"
			host_path = "/opt/mount1/grafana"
		}
  volume {
			name = "grafana_plugins"
			host_path = "/opt/mount1/grafana/plugins"
		}
  volume {
			name = "grafana_logs",
			host_path = "/opt/mount1/grafana_logs"
		}
  volume {
			name = "graphite_config",
			host_path = "/opt/mount1/graphite/conf"
		}
  volume {
			name = "graphite_stats_storage",
			host_path = "/opt/mount1/graphite/storage"
		}
  volume {
			name = "nginx_config",
			host_path = "/opt/mount1/nginx_config"
		}
  volume {
			name = "statsd_config",
			host_path = "/opt/mount1/statsd_config"
		}
  volume {
			name = "graphite_logrotate_config",
			host_path = "/etc/logrotate.d"
		}
  volume {
			name = "graphite_log_files",
			host_path = "/opt/mount1/graphite_log_files"
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
		          "hostPort": 8600,
		          "containerPort": 8600,
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
		    "essential": false,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:0.1.1",
		    "memory": 100,
		    "environment": [
		    	{
		    		"Name": "GRAPHITE_HOST",
		    		"Value": "172.17.0.1"
		    	}, 
		    	{
		    		"Name": "GRAPHITE_PREFIX",
		    		"Value": "${var.ecosystem}.${var.environment}.graphite."
		    	}
		    ]
		},
		{
		    "name": "graphite-statsd",
		    "cpu": 0,
		    "essential": true,
		    "image": "graphiteapp/graphite-statsd:latest",
		    "memory": 400,
		    "portMappings": [
		        {
		          "hostPort": 80,
		          "containerPort": 80,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2003,
		          "containerPort": 2003,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2004,
		          "containerPort": 2004,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2023,
		          "containerPort": 2023,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2024,
		          "containerPort": 2024,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 8125,
		          "containerPort": 8125,
		          "protocol": "udp"
		        },
		        {
		          "hostPort": 8126,
		          "containerPort": 8126,
		          "protocol": "udp"
		        }
		    ],
			"mountPoints": [
                {
                  "sourceVolume": "graphite_config",
                  "containerPath": "/opt/graphite/conf",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_stats_storage",
                  "containerPath": "/opt/graphite/storage",
                  "readOnly": false
                },
                {
                  "sourceVolume": "nginx_config",
                  "containerPath": "/etc/nginx",
                  "readOnly": false
                },
                {
                  "sourceVolume": "statsd_config",
                  "containerPath": "/opt/statsd",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_logrotate_config",
                  "containerPath": "/etc/logrotate.d",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_log_files",
                  "containerPath": "/var/log/graphite",
                  "readOnly": false
                }
            ]
        },
		{
		    "name": "grafana",
		    "cpu": 0,
		    "essential": true,
		    "image": "grafana/grafana",
		    "memory": 500,
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

resource "aws_lb_cookie_stickiness_policy" "grafana" {
  name                     = "grafana"
  load_balancer            = "${aws_elb.grafana.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_elb" "grafana" {
  name            = "grafana"
  security_groups = ["${aws_security_group.grafana.id}"]
  subnets = ["${aws_subnet.monitoring.id}"]
  depends_on = ["aws_security_group.grafana"]
  
  listener {
    instance_port      = 3000
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }  

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/api/health"
    interval            = 30
  }
}

resource "aws_route53_record" "grafana" {
	zone_id = "${aws_route53_zone.root.zone_id}"
	name    = "grafana"
    type    = "CNAME"
    ttl     = 300
    records = ["${aws_elb.grafana.dns_name}"]
    depends_on = ["aws_route53_zone.root", "aws_elb.grafana"]
}

resource "aws_elb_attachment" "grafana" {
  count = "1" 
  elb      = "${aws_elb.grafana.id}"
  instance = "${aws_instance.graphite.id}"
}

resource "aws_route_table" "monitoring" {
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name = "monitoring-${var.nameTag}"
    Ecosystem = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer = "monitoring"
  }
}

resource "aws_route" "monitoring" {
  route_table_id = "${aws_route_table.monitoring.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
  
  depends_on = ["aws_route_table.monitoring", "aws_internet_gateway.default"]
}

resource "aws_subnet" "monitoring" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.monitoring_subnet}"
  availability_zone = "${var.availability_zone}"
  depends_on      = ["aws_vpc.default"]

  tags {
    Name = "monitoring-${var.nameTag}"
  }
}

resource "aws_route_table_association" "monitoring" {
  subnet_id      = "${aws_subnet.monitoring.id}"
  route_table_id = "${aws_route_table.monitoring.id}"
  depends_on = ["aws_route_table.monitoring", "aws_subnet.monitoring"]
}

resource "aws_security_group" "graphite" {
  name        = "graphite-${var.nameTag}"
  
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]
  
  ingress {
    from_port   = 2003
    to_port     = 2003
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "udp"
    cidr_blocks = ["${var.ecosystem_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}","${var.admin_cidr}"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${var.ecosystem_cidr}","${var.admin_cidr}"]
  }

  tags {
    Name = "graphite-${var.nameTag}"
    Ecosystem = "${var.ecosystem}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "grafana" {
  name        = "grafana"
  
  description = "grafana security group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "grafana-${var.nameTag}"
    Ecosystem = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer = "grafana"
  }
}
