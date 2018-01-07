resource "aws_ebs_volume" "nexus" {
	availability_zone = "${var.availability_zone}"
    size = 22
    tags {
        Name = "nexus"
    }
}

resource "aws_volume_attachment" "nexus" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.nexus.id}"
  instance_id = "${aws_instance.nexus.id}"
  force_detach =false
  depends_on      = ["aws_ebs_volume.nexus", "aws_instance.nexus"]
}

resource "aws_instance" "nexus" {
	count = "1"
	ami = "${var.ecs_ami_id}"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.small"
    key_name = "poc"
    private_ip = "${var.nexus_ip}"
    monitoring = "false",
    vpc_security_group_ids = [
    	"${aws_security_group.nexus.id}",
    	"${aws_security_group.ssh.id}",
    	"${aws_security_group.consul-client.id}"
    ],
    subnet_id = "${aws_subnet.nexus.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
	user_data = <<EOF
#!/bin/bash
mkdir /opt/mount1
mount /dev/xvdh /opt/mount1
echo /dev/xvdh  /opt/mount1 ext4 defaults,nofail 0 2 >> /etc/fstab
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=nexus
EOF

  tags {
    Name = "nexus-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	ConsulCluster = "${var.nameTag}"
  }
}

resource "aws_ecs_cluster" "nexus" {
  name = "nexus"
}

resource "aws_ecs_service" "nexus" {
  name            = "nexus"
  cluster         = "nexus"
  task_definition = "nexus:${aws_ecs_task_definition.nexus.revision}"
  depends_on = ["aws_ecs_cluster.nexus", "aws_instance.nexus"]
  desired_count   = 1
}

resource "aws_ecs_task_definition" "nexus" {
  family = "nexus"
  network_mode = "host"
  volume {
			name = "nexus-data"
			host_path = "/opt/mount1/nexus"
		}
  container_definitions = <<DEFINITION
	[
		{
			"name": "collectd",
			"cpu": 0,
		    "essential": false,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:0.1.1",
		    "memory": 500,
		    "environment": [
		    	{
		    		"Name": "GRAPHITE_HOST",
		    		"Value": "10.0.0.36"
		    	}, 
		    	{
		    		"Name": "GRAPHITE_PREFIX",
		    		"Value": "${var.ecosystem}.${var.environment}.nexus."
		    	}
		    ]
		},
		{
			"name": "nexus",
			"cpu": 0,
		    "essential": true,
		    "image": "sonatype/nexus:oss",
		    "memory": 500,
		    "portMappings": [
		        {
		          "hostPort": 8081,
		          "containerPort": 8081,
		          "protocol": "tcp"
		        }
		    ],
		    "mountPoints": [
                {
                  "sourceVolume": "nexus-data",
                  "containerPath": "/sonatype-work",
                  "readOnly": false
                }
            ]
		}
	]
    DEFINITION
}

resource "aws_lb_cookie_stickiness_policy" "nexus" {
  name                     = "nexus"
  load_balancer            = "${aws_elb.nexus.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_elb" "nexus" {
  name            = "nexus"
  security_groups = ["${aws_security_group.nexus.id}"]
  subnets = ["${aws_subnet.nexus.id}"]
  depends_on = ["aws_security_group.nexus"]
  
  listener {
    instance_port      = 8081
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }  

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8081/nexus/service/local/status"
    interval            = 30
  }
}

resource "aws_route53_record" "nexus" {
	zone_id = "${aws_route53_zone.root.zone_id}"
	name    = "nexus"
    type    = "A"
    depends_on = ["aws_route53_zone.root", "aws_elb.nexus"]

	alias {
		 name = "${aws_elb.nexus.dns_name}"
		 zone_id = "${aws_elb.nexus.zone_id}"
		 evaluate_target_health = "true"
	}
}

resource "aws_elb_attachment" "nexus" {
  count = "1" 
  elb      = "${aws_elb.nexus.id}"
  instance = "${aws_instance.nexus.id}"
}

resource "aws_route_table" "nexus" {
  vpc_id = "${aws_vpc.default.id}"
  depends_on = ["aws_vpc.default"]

  tags {
    Name = "nexus-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "nexus"
  }
}

resource "aws_route" "nexus" {
  route_table_id = "${aws_route_table.nexus.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
  
  depends_on = ["aws_route_table.nexus", "aws_internet_gateway.default"]
}

resource "aws_subnet" "nexus" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.nexus_subnet}"
  availability_zone = "${var.availability_zone}"
  depends_on      = ["aws_vpc.default"]

  tags {
    Name = "nexus-${var.nameTag}"
  }
}

resource "aws_route_table_association" "nexus" {
  subnet_id      = "${aws_subnet.nexus.id}"
  route_table_id = "${aws_route_table.nexus.id}"
  depends_on = ["aws_route_table.nexus", "aws_subnet.nexus"]
}

resource "aws_security_group" "nexus" {
  name        = "nexus"
  
  description = "nexus security group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }
  
  ingress {
    from_port   = 8081
    to_port     = 8081
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
    Name = "nexus-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	Layer = "nexus"
  }
}








