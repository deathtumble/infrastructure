module "instance" {
  source = "../ephemeralinstance"

  role = "${var.role}"

  vpc_security_group_ids = [
    "${aws_security_group.concourse.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
  ]

  instance_type            = "${var.instance_type}"

  // globals
  key_name                 = "${var.key_name}"
  aws_subnet_id            = "${aws_subnet.av1.id}"
  vpc_id                   = "${aws_vpc.default.id}"
  availability_zone        = "${var.availability_zone_1}"
  ami_id                   = "${var.ecs_ami_id}"
  product                  = "${var.product}"
  environment              = "${var.environment}"
}

