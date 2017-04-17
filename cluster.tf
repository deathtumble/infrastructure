resource "aws_ecs_service" "helloworld" {
  name            = "helloworld"
  cluster         = "helloworld"
  task_definition = "helloworld:${aws_ecs_task_definition.helloworld.revision}"
  desired_count   = 1

}

resource "aws_ecs_cluster" "helloworld" {
  name = "helloworld"
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
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/helloworld-http:latest",
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

