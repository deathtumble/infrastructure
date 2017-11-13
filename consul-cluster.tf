resource "aws_ecs_cluster" "consul-leader" {
  name = "consul-leader"
}

resource "aws_ecs_service" "consul-leader" {
  name            = "consul-leader"
  cluster         = "consul-leader"
  task_definition = "consul-leader:${aws_ecs_task_definition.consul-leader.revision}"
  desired_count   = 1
}

resource "aws_ecs_task_definition" "consul-leader" {
  family = "consul-leader"
  network_mode = "host"
  
  container_definitions = <<DEFINITION
	[
		{
		    "name": "consul-leader",
		    "cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/consul:0.1.0",
		    "memory": 500,
		    "environment": [
		    	{
		    		"Name": "CONSUL_LOCAL_CONFIG",
		    		"Value": "{\"skip_leave_on_interrupt\": true}"
		    	},
		    	{
		    		"Name": "CONSUL_BIND_INTERFACE",
		    		"Value": "eth0"
		    	}, 
		    	{
		    		"Name": "CONSUL_CLIENT_INTERFACE",
		    		"Value": "eth0"
		    	}
		    ],
		    "command": [
        		"agent",
        		"-server",
        		"-bootstrap",
        		"-retry-join",
        		"provider=aws tag_key=ConsulCluster tag_value=${var.nameTag}",
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
		          "hostPort": 8600,
		          "containerPort": 8600,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 8600,
		          "containerPort": 8600,
		          "protocol": "udp"
		        }
		    ]
      	}
	]
    DEFINITION
}

resource "aws_ecs_cluster" "consul-server" {
  name = "consul-server"
}

resource "aws_ecs_service" "consul-server" {
  name            = "consul-server"
  cluster         = "consul-server"
  task_definition = "consul-server:${aws_ecs_task_definition.consul-server.revision}"
  desired_count   = 2
}

resource "aws_ecs_task_definition" "consul-server" {
  family = "consul-server"
  network_mode = "host"
  
  container_definitions = <<DEFINITION
	[
		{
		    "name": "consul-server",
		    "cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/consul:0.1.0",
		    "memory": 1024,
		    "environment": [
		    	{
		    		"Name": "CONSUL_LOCAL_CONFIG",
		    		"Value": "{\"skip_leave_on_interrupt\": true}"
		    	},
		    	{
		    		"Name": "CONSUL_BIND_INTERFACE",
		    		"Value": "eth0"
		    	}, 
		    	{
		    		"Name": "CONSUL_CLIENT_INTERFACE",
		    		"Value": "eth0"
		    	}
		    ],
		    "command": [
        		"agent",
        		"-server",
        		"-retry-join",
        		"provider=aws tag_key=ConsulCluster tag_value=${var.nameTag}",
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
		          "hostPort": 8600,
		          "containerPort": 8600,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 8600,
		          "containerPort": 8600,
		          "protocol": "udp"
		        }
		    ]
      	}
	]
    DEFINITION
}
