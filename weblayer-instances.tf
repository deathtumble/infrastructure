resource "aws_instance" "weblayer" {
	ami = "ami-95f8d2f3"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.micro"
    key_name = "poc"
    monitoring = "false",
    vpc_security_group_ids = ["${aws_security_group.weblayer.id}"]
    subnet_id = "${data.aws_subnet.weblayer.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
	user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=weblayer > /etc/ecs/ecs.config
EOF

  tags {
    Name = "weblayer-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
  }
}

