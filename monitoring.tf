resource "aws_instance" "graphite" {
	count = "1"
	ami = "${var.ecs_ami_id}"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.small"
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
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=graphite
EOF

  tags {
    Name = "graphite-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	ConsulCluster = "${var.nameTag}"
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
			name = "whisper"
			host_path = "/var/lib/gmonitor/graphite/whisper"
		}
  volume {
			name = "config"
			host_path = "/var/lib/gmonitor/graphite/conf"
		}
  volume {
			name = "grafana",
			host_path = "/var/lib/gmonitor/grafana/data"
		}
  
  container_definitions = <<DEFINITION
	[
		{
			"name": "collectd",
			"cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:0.1.1",
		    "memory": 500,
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
		    "name": "graphite",
		    "cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/graphite-grafana:0.1.0",
		    "memory": 500,
		    "volumes": [
		    	{
		    		"name": "whisper",
		    		"host": "/var/lib/gmonitor/graphite/whisper",
		    		"sourcePath": "/var/lib/graphite/storage/whisper"
		    	},
		    	{
		    		"name": "config",
		    		"host": "/var/lib/gmonitor/graphite/conf",
		    		"sourcePath": "/var/lib/graphite/conf"
		    	},
		    	{
		    		"name": "grafana",
		    		"host": "/var/lib/gmonitor/grafana/data",
		    		"sourcePath": "/usr/share/grafana/data"
		    	}
		    ],
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
		          "hostPort": 3000,
		          "containerPort": 3000,
		          "protocol": "udp"
		        }
		    ]
      	}
	]
    DEFINITION
}

