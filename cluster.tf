resource "aws_ecs_service" "helloworld" {
  name            = "helloworld"
  cluster         = "default"
  task_definition = "helloworld:3"
  desired_count   = 1
}

resource "aws_ecs_task_definition" "helloworld" {
  family = "helloworld"
  network_mode = "bridge"

  container_definitions = <<DEFINITION
	[
		{
		    "name": "helloworld",
		    "cpu": 0,
		    "essential": true,
		    "image": "helloworld-http:latest",
		    "memory": 128,
		    "portMappings": [
		    	{
		    		"containerPort": 80,
		    		"hostPort": 80
		    	}
		    ]
		}
	]
DEFINITION
}

