variable "consul_server_instance_names" {
  default = {
    "0" = "1"
    "1" = "2"
    "2" = "3"
  }
}

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
    subnet_id = "${aws_subnet.consul.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
    depends_on      = ["aws_security_group.consul", "aws_subnet.consul"]
	user_data = <<EOF
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=consul-leader
HOST_NAME=consul-${var.nameTag}-leader
EOF

  tags {
    Name = "consul-${var.nameTag}-leader"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	ConsulCluster = "${var.nameTag}"
  }
}

resource "aws_elb_attachment" "consul-leader" {
  elb      = "${aws_elb.consului.id}"
  instance = "${aws_instance.consul-leader.id}"
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
    subnet_id = "${aws_subnet.consul.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
    depends_on      = ["aws_security_group.consul", "aws_subnet.consul"]
	user_data = <<EOF
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=consul-server
HOST_NAME=consul-${var.nameTag}-${lookup(var.consul_server_instance_names, count.index)}
EOF

  tags {
    Name = "consul-${var.nameTag}-${lookup(var.consul_server_instance_names, count.index)}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	ConsulCluster = "${var.nameTag}"
  }
}

resource "aws_elb_attachment" "consul-server" {
  count = "2" 
  elb      = "${aws_elb.consului.id}"
  instance = "${aws_instance.consul-server.*.id[count.index]}"
}

