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
	ConsulCluster = "${var.nameTag}"
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
		    		"Value": "10.0.0.36"
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

