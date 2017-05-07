resource "aws_s3_bucket" "zookeeper" {
  bucket = "zookeeper.453254632971"
  acl    = "private"
  region = "${var.region}"

  tags {
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_iam_instance_profile" "zookeeper" {
  name  = "zookeeper_profile"
  role = "zookeeper_role"
}

variable "zookeeper_instance_ips" {
  default = {
    "0" = "10.0.0.68"
    "1" = "10.0.0.69"
    "2" = "10.0.0.70"
  }
}

variable "zookeeper_instance_names" {
  default = {
    "0" = "1"
    "1" = "2"
    "2" = "3"
  }
}

resource "aws_instance" "zookeeper" {
	count = "3"
	ami = "ami-95f8d2f3"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.small"
    key_name = "poc"
    private_ip = "${lookup(var.zookeeper_instance_ips, count.index)}"
    monitoring = "false",
    vpc_security_group_ids = ["${aws_security_group.zookeeper.id}"]
    subnet_id = "${data.aws_subnet.zookeeper.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "zookeeper_role",
	ipv6_address_count = "0",
	user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=zookeeper > /etc/ecs/ecs.config
mkdir /etc/zookeeper
echo ${lookup(var.zookeeper_instance_names, count.index)} > /etc/zookeeper/zookeeper.config
EOF

  tags {
    Name = "zookeeper-${var.nameTag}-${lookup(var.zookeeper_instance_names, count.index)}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

resource "aws_ecs_cluster" "zookeeper" {
  name = "zookeeper"
}

resource "aws_ecs_service" "zookeeper" {
  name            = "zookeeper"
  cluster         = "zookeeper"
  task_definition = "zookeeper:${aws_ecs_task_definition.zookeeper.revision}"
  desired_count   = 3
}

resource "aws_ecs_task_definition" "zookeeper" {
  family = "zookeeper"
  network_mode = "bridge"
  
  volume {
    name      = "zookeeper"
    host_path = "/etc/zookeeper"
  }
  
  container_definitions = <<DEFINITION
	[
		{
		    "name": "zookeeper",
		    "cpu": 1,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/zookeeper:latest",
		    "memory": 1024,
      		"mountPoints": [
        		{
          			"containerPath": "/zookeeper",
          			"sourceVolume": "zookeeper",
          			"readOnly": null
        		}
      		],		    
		    "portMappings": [
		    	{
		    	
		    		"containerPort": 2181,
		    		"hostPort": 2181
		    	},
		    	{
		    		"containerPort": 2888,
		    		"hostPort": 2888
		    	},
		    	{
		    		"containerPort": 3888,
		    		"hostPort": 3888
		    	}
		    ],
		    "environment": [
		    	{
		    		"name": "ZOOKEEPER_SERVER_2",
		    		"value": "10.0.0.69"
		    	},
		    	{
		    		"name": "ZOOKEEPER_SERVER_1",
		    		"value": "10.0.0.68"
		    	},
		    	{
		    		"name": "ZOOKEEPER_SERVER_3",
		    		"value": "10.0.0.70"
		    	}
		    ]
		}
	]
DEFINITION
}


