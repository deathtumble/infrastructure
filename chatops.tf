resource "aws_instance" "chatops" {
	count = "1"
	ami = "${var.ecs_ami_id}"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.small"
    key_name = "poc"
    private_ip = "10.0.0.68"
    monitoring = "false",
    vpc_security_group_ids = [
    	"${aws_security_group.chatops.id}",
    	"${aws_security_group.ssh.id}",
    	"${aws_security_group.consul-client.id}"
    ],
    subnet_id = "${aws_subnet.chatops.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
    depends_on      = ["aws_security_group.chatops", "aws_security_group.ssh", "aws_security_group.consul-client", "aws_subnet.consul"]
	user_data = <<EOF
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=chatops
EOF

  tags {
    Name = "chatops-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_ecs_cluster" "chatops" {
  name = "chatops"
}

resource "aws_ecs_service" "chatops" {
  name            = "chatops"
  cluster         = "chatops"
  task_definition = "chatops:${aws_ecs_task_definition.chatops.revision}"
  depends_on = ["aws_ecs_cluster.chatops", "aws_ecs_task_definition.chatops"]
  desired_count   = 1
}

resource "aws_ecs_task_definition" "chatops" {
  family = "chatops"
  network_mode = "host"
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
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:0.1.1",
		    "memory": 500,
		    "environment": [
		    	{
		    		"Name": "GRAPHITE_HOST",
		    		"Value": "graphite.service.consul"
		    	}, 
		    	{
		    		"Name": "GRAPHITE_PREFIX",
		    		"Value": "${var.ecosystem}.${var.environment}.chatops."
		    	}
		    ]
		},
		{
		    "name": "hubot",
		    "cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/alpine-hubot:0.1.3",
		    "memory": 500,
		    "environment": [
		    	{
		    		"Name": "HUBOT_GRAFANA_HOST",
		    		"Value": "10.0.0.36"
		    	},
		    	{
		    		"Name": "HUBOT_GRAFANA_API_KEY",
		    		"Value": "${var.higgins_grafana_api_key}"
		    	},
		    	{
		    		"Name": "HUBOT_GRAFANA_S3_BUCKET",
		    		"Value": "${var.higgin_grafana_s3_bucket}"
		    	},
		    	{
		    		"Name": "HUBOT_GRAFANA_S3_ACCESS_KEY_ID",
		    		"Value": "${var.higgins_grafana_s3_access_key_id}"
		    	},
		    	{
		    		"Name": "HUBOT_GRAFANA_S3_SECRET_ACCESS_KEY",
		    		"Value": "${var.higgin_grafana_s3_secret_access_key}"
		    	},
		    	{
		    		"Name": "HUBOT_GRAFANA_S3_PREFIX",
		    		"Value": "${var.higgin_grafana_s3_prefix}"
		    	},
		    	{
		    		"Name": "HUBOT_SLACK_TOKEN",
		    		"Value": "${var.hubot_slack_token}"
		    	}
		    ],
		    "portMappings": [
		        {
		          "hostPort": 80,
		          "containerPort": 80,
		          "protocol": "tcp"
		        }
		    ]
      	}
	]
    DEFINITION
}

resource "aws_route_table" "chatops" {
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name = "chatops-${var.nameTag}"
    Ecosystem = "${var.ecosystem}"
    Environment = "${var.environment}"
    Layer = "chatops"
  }
}

resource "aws_route" "chatops" {
  route_table_id = "${aws_route_table.chatops.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
  
  depends_on = ["aws_route_table.chatops", "aws_internet_gateway.default"]
}

resource "aws_subnet" "chatops" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.chatops_subnet}"
  availability_zone = "${var.availability_zone}"
  depends_on      = ["aws_vpc.default"]

  tags {
    Name = "chatops-${var.nameTag}"
  }
}

resource "aws_route_table_association" "chatops" {
  subnet_id      = "${aws_subnet.chatops.id}"
  route_table_id = "${aws_route_table.chatops.id}"
  depends_on = ["aws_route_table.chatops", "aws_subnet.chatops"]
}

resource "aws_security_group" "chatops" {
  name        = "chatops-${var.nameTag}"
  
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

  tags {
    Name = "graphite-${var.nameTag}"
    Ecosystem = "${var.ecosystem}"
    Environment = "${var.environment}"
  }
}

