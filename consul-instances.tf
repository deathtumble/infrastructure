resource "aws_instance" "consul-leader" {
	count = "1"
	ami = "ami-95f8d2f3"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.small"
    key_name = "poc"
    private_ip = "10.0.0.68"
    monitoring = "false",
    vpc_security_group_ids = ["${aws_security_group.consul.id}"]
    subnet_id = "${data.aws_subnet.consul.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
	user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=consul-leader > /etc/ecs/ecs.config
EOF

  tags {
    Name = "consul-${var.nameTag}-leader"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	ConsulCluster = "${var.nameTag}"
  }
}

resource "aws_instance" "consul-server" {
	count = "2"
	ami = "ami-95f8d2f3"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.small"
    key_name = "poc"
    private_ip = "${lookup(var.consul_server_instance_ips, count.index)}"
    monitoring = "false",
    vpc_security_group_ids = ["${aws_security_group.consul.id}"]
    subnet_id = "${data.aws_subnet.consul.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
	user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=consul-server > /etc/ecs/ecs.config
EOF

  tags {
    Name = "consul-${var.nameTag}-${lookup(var.consul_server_instance_names, count.index)}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	ConsulCluster = "${var.nameTag}"
  }
}

