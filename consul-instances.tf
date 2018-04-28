variable "consul_server_instance_names" {
  default = {
    "0" = "1"
    "1" = "2"
    "2" = "3"
  }
}

resource "aws_instance" "consul-leader" {
  count                   = "1"
  ami                     = "${var.ecs_ami_id}"
  availability_zone       = "${var.availability_zone_1}"
  tenancy                 = "default"
  ebs_optimized           = "false"
  disable_api_termination = "false"
  instance_type           = "t2.small"
  key_name                = "${var.key_name}"
  monitoring              = "false"

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-server.id}",
  ]

  subnet_id                   = "${aws_subnet.av1.id}"
  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=consul-leader
HOSTNAME=consul-${var.product}-${var.environment}-leader
EOF

  tags {
    Name          = "consul-0"
    Product       = "${var.product}"
    Environment   = "${var.environment}"
    ConsulCluster = "${var.product}-${var.environment}"
  }
}

resource "aws_elb_attachment" "consul-leader" {
  elb      = "${aws_elb.consului.id}"
  instance = "${aws_instance.consul-leader.id}"
}

resource "aws_instance" "consul-server" {
  count                   = "${var.consul_server_count}"
  ami                     = "${var.ecs_ami_id}"
  availability_zone       = "${var.availability_zone_1}"
  tenancy                 = "default"
  ebs_optimized           = "false"
  disable_api_termination = "false"
  instance_type           = "t2.small"
  key_name                = "${var.key_name}"
  monitoring              = "false"

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-server.id}",
  ]

  subnet_id                   = "${aws_subnet.av1.id}"
  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=consul-server
HOST_NAME=consul-${var.product}-${var.environment}-${lookup(var.consul_server_instance_names, count.index)}
EOF

  tags {
    Name          = "consul-${lookup(var.consul_server_instance_names, count.index)}"
    Product       = "${var.product}"
    Environment   = "${var.environment}"
    ConsulCluster = "${var.product}-${var.environment}"
  }
}

resource "aws_elb_attachment" "consul-server" {
  count    = "${var.consul_server_count}"
  elb      = "${aws_elb.consului.id}"
  instance = "${aws_instance.consul-server.*.id[count.index]}"
}
