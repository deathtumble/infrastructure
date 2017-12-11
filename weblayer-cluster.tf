variable "weblayer_count" {
	type = "string"
	default = "1"
}

resource "aws_ecs_cluster" "weblayer" {
  name            = "weblayer"
  depends_on      = ["aws_instance.weblayer"]
}

resource "aws_ecs_service" "weblayer" {
  name            = "weblayer"
  cluster         = "weblayer"
  task_definition = "weblayer:${aws_ecs_task_definition.weblayer.revision}"
  desired_count   = "${var.weblayer_count}"
  depends_on      = ["aws_ecs_task_definition.weblayer", "aws_ecs_cluster.weblayer"]
}

resource "aws_ecs_task_definition" "weblayer" {
  family = "weblayer"
  network_mode = "host"
  
  container_definitions = <<DEFINITION
	[
		{
		    "name": "web_layer",
		    "cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/greeting:0.1.0",
		    "memory": 500,
		    "portMappings": [
		    	{
		    		"containerPort": 80,
		    		"hostPort": 80
		    	}
		    ]
		},
		{
		    "name": "web_layer",
		    "cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:0.1.0",
		    "memory": 500,
		    "environment": [
		    	{
		    		"Name": "HOST_NAME=desktop",
		    		"Value": "{\"leave_on_terminate\": true}"
		    	},
		    	{
		    		"Name": "GRAPHITE_HOST=172.17.0.2",
		    		"Value": "eth0"
		    	}, 
		    	{
		    		"Name": "GRAPHITE_PREFIX=test.desktop.",
		    		"Value": "eth0"
		    	}
		    ],
		    "portMappings": [
		    	{
		    		"containerPort": 80,
		    		"hostPort": 80
		    	}
		    ]
		},
		{
		    "name": "consul-server",
		    "cpu": 0,
		    "essential": true,
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
		    		"Value": "eth0"
		    	}
		    ],
		    "command": [
        		"agent",
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
