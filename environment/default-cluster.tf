
module "default-instance" {
  source = "../ephemeralinstance"

  count             = "3"
  role              = "default"
  instance_type     = "t2.medium"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${var.availability_zone_1}"
  subnet_id         = "${aws_subnet.av1.id}"
  ami_id            = "${var.ecs_ami_id}"
  cluster_name      = "default"

  vpc_security_group_ids = [
    "${aws_security_group.aws-proxy.id}",
    "${aws_security_group.dashing.id}",
    "${aws_security_group.concourse.id}",
    "${aws_security_group.os.id}",
  ]

  globals = "${var.globals}"
}

resource "aws_ecs_cluster" "default" {
  name = "default-${local.environment}"
}

