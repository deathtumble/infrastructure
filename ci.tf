resource "aws_ebs_volume" "concourse" {
	availability_zone = "${var.availability_zone}"
    size = 22
    tags {
        Name = "concourse"
    }
}

resource "aws_volume_attachment" "concourse" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.concourse.id}"
  instance_id = "${aws_instance.concourse.id}"
  force_detach = true
  depends_on      = ["aws_ebs_volume.concourse", "aws_instance.concourse"]
}

resource "aws_instance" "concourse" {
	count = "1"
	ami = "${var.ecs_ami_id}"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.medium"
    key_name = "poc"
    private_ip = "${var.concourse_ip}"
    monitoring = "false",
    vpc_security_group_ids = [
    	"${aws_security_group.concourse.id}",
    	"${aws_security_group.ssh.id}",
    	"${aws_security_group.consul-client.id}"
    ],
    subnet_id = "${aws_subnet.concourse.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
	user_data = <<EOF
#cloud-config
hostname: monitoring
write_files:
 - content: ECS_CLUSTER=concourse
   path: /etc/ecs/ecs.config   
   permissions: 644
 - content: ${base64encode(file("files/concourse_consul.json"))}
   path: /opt/consul/conf/concourse_consul.json
   encoding: b64
   permissions: 644
 - content: ${base64encode(file("files/concourse_goss.yml"))}
   path: /etc/goss/goss.yaml
   encoding: b64
   permissions: 644
runcmd:
 - mkdir /opt/mount1
 - sleep 18
 - sudo mount /dev/xvdh /opt/mount1
 - sudo echo /dev/xvdh  /opt/mount1 ext4 defaults,nofail 0 2 >> /etc/fstab
 - chmod 644 /opt/consul/conf/concourse_consul.json
 - sudo mount -a
 - service goss start
EOF

  tags {
    Name = "concourse"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_ecs_cluster" "concourse" {
  name = "concourse"
}

resource "aws_ecs_service" "concourse" {
  name            = "concourse"
  cluster         = "concourse"
  task_definition = "concourse:${aws_ecs_task_definition.concourse.revision}"
  depends_on = ["aws_ecs_cluster.concourse", "aws_instance.concourse"]
  desired_count   = 1
}

resource "aws_ecs_task_definition" "concourse" {
  family = "concourse"
  network_mode = "host"
  volume {
			name = "postgres_data"
			host_path = "/opt/mount1/database"
		}
		
  volume {
			name = "concourse_web_keys"
			host_path = "/opt/mount1/keys/web"
		}

  volume {
			name = "concourse_worker_keys"
			host_path = "/opt/mount1/keys/worker"
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
		    		"Value": "${var.ecosystem}.${var.environment}.concourse."
		    	}
		    ]
		},
		{
		    "name": "concourse-db",
		    "cpu": 0,
		    "essential": true,
		    "image": "postgres:9.6",
		    "memory": 500,
		    "environment": [
		    	{
		    		"Name": "POSTGRES_DB",
		    		"Value": "concourse"
		    	}, 
		    	{
		    		"Name": "POSTGRES_USER",
		    		"Value": "concourse"
		    	}, 
		    	{
		    		"Name": "POSTGRES_PASSWORD",
		    		"Value": "${var.concourse_postgres_password}"
		    	}, 
		    	{
		    		"Name": "PGDATA",
		    		"Value": "/database"
		    	}
		    ],
		    "mountPoints": [
		    	{
		    		"sourceVolume": "postgres_data",
		    		"containerPath": "/database",
		    		"readOnly": false
		    	}
		    ],
		    "portMappings": [
		        {
		          "hostPort": 5432,
		          "containerPort": 5432,
		          "protocol": "tcp"
		        }
		    ]
      	},
      	{
		    "name": "concourse-web",
		    "cpu": 0,
		    "essential": true,
		    "image": "concourse/concourse",
		    "command": ["web"],
		    "memory": 500,
		    "portMappings": [
		        {
		          "hostPort": 8080,
		          "containerPort": 8080,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2222,
		          "containerPort": 2222,
		          "protocol": "tcp"
		        }
		    ],
		    "mountPoints": [
                {
                  "sourceVolume": "concourse_web_keys",
                  "containerPath": "/concourse-keys",
                  "readOnly": false
                }
            ],
		    "environment": [
		    	{
		    		"Name": "CONCOURSE_BASIC_AUTH_USERNAME",
		    		"Value": "concourse"
		    	}, 
		    	{
		    		"Name": "CONCOURSE_BASIC_AUTH_PASSWORD",
		    		"Value": "${var.concourse_password}"
		    	}, 
		    	{
		    		"Name": "CONCOURSE_EXTERNAL_URL",
		    		"Value": "http://concourse.${var.root_domain_name}"
		    	}, 
		    	{
		    		"Name": "CONCOURSE_POSTGRES_HOST",
		    		"Value": "172.17.0.1"
		    	}, 
		    	{
		    		"Name": "CONCOURSE_POSTGRES_USER",
		    		"Value": "concourse"
		    	}, 
		    	{
		    		"Name": "CONCOURSE_POSTGRES_PASSWORD",
		    		"Value": "${var.concourse_postgres_password}"
		    	}, 
		    	{
		    		"Name": "CONCOURSE_POSTGRES_DATABASE",
		    		"Value": "concourse"
		    	}
		    ]
      	},
      	{
		    "name": "concourse-worker",
		    "cpu": 0,
		    "essential": false,
		    "privileged": true,
		    "image": "concourse/concourse",
		    "command": ["worker"],
		    "memory": 500,
		    "mountPoints": [
                {
                  "sourceVolume": "concourse_worker_keys",
                  "containerPath": "/concourse-keys",
                  "readOnly": false
                }
            ],
		    "environment": [
		    	{
		    		"Name": "CONCOURSE_TSA_HOST",
		    		"Value": "172.17.0.1"
		    	}
		    ]
		 } 
	]
    DEFINITION
}

resource "aws_lb_cookie_stickiness_policy" "concourse" {
  name                     = "concourse"
  load_balancer            = "${aws_elb.concourse.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_elb" "concourse" {
  name            = "concourse"
  security_groups = ["${aws_security_group.concourse.id}"]
  subnets = ["${aws_subnet.concourse.id}"]
  depends_on = ["aws_security_group.concourse"]
  
  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }  

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }
}

resource "aws_route53_record" "concourse" {
	zone_id = "${aws_route53_zone.root.zone_id}"
	name    = "concourse"
    type    = "CNAME"
    ttl     = 300
    records = ["${aws_elb.concourse.dns_name}"]
    depends_on = ["aws_route53_zone.root", "aws_elb.concourse"]
}

resource "aws_elb_attachment" "concourse" {
  count = "1" 
  elb      = "${aws_elb.concourse.id}"
  instance = "${aws_instance.concourse.id}"
}

resource "aws_route_table" "concourse" {
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name = "concourse-${var.nameTag}"
    Ecosystem = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer = "concourse"
  }
}

resource "aws_route" "concourse" {
  route_table_id = "${aws_route_table.concourse.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
  
  depends_on = ["aws_route_table.concourse", "aws_internet_gateway.default"]
}

resource "aws_subnet" "concourse" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.concourse_subnet}"
  availability_zone = "${var.availability_zone}"
  depends_on      = ["aws_vpc.default"]

  tags {
    Name = "concourse-${var.nameTag}"
  }
}

resource "aws_route_table_association" "concourse" {
  subnet_id      = "${aws_subnet.concourse.id}"
  route_table_id = "${aws_route_table.concourse.id}"
  depends_on = ["aws_route_table.concourse", "aws_subnet.concourse"]
}

resource "aws_security_group" "concourse" {
  name        = "concourse"
  
  description = "concourse security group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.admin_cidrs}"
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}","${var.ecosystem_cidr}"]
  }
  
  ingress {
    from_port   = 8082
    to_port     = 8082
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
    Name = "concourse-${var.nameTag}"
    Ecosystem = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer = "concourse"
  }
}
