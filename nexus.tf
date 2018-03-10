module "nexus" {
  source = "./role"

  role = "nexus"

  vpc_security_group_ids = [
    "${aws_security_group.nexus.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.consul-client.id}",
  ]

  elb_security_group   = "${aws_security_group.nexus.id}"
  elb_instance_port    = "8081"
  elb_port             = "80"
  healthcheck_port     = "8081"
  healthcheck_protocol = "HTTP"
  healthcheck_path     = "/nexus/service/local/status"
  task_definition      = "nexus:${aws_ecs_task_definition.nexus.revision}"
  desired_count        = "1"

  volume_id = "${var.nexus_volume_id}"

  // todo remove need to specify    
  cidr_block = "${var.nexus_subnet}"
  private_ip = "${var.nexus_ip}"

  // globals
  vpc_id                     = "${var.aws_vpc_id}"
  gateway_id                 = "${aws_internet_gateway.default.id}"
  availability_zone          = "${var.availability_zone}"
  ami_id                     = "${var.ecs_ami_id}"
  product                  = "${var.product}"
  environment                = "${var.environment}"
  aws_route53_record_zone_id = "${var.aws_route53_zone_id}"
}

data "template_file" "nexus" {
  template = "${file("files/nexus_container.tpl")}"
}

data "template_file" "collectd-nexus" {
  template = "${file("files/collectd.tpl")}"

  vars {
    graphite_prefix = "${var.product}.${var.environment}.nexus."
  }
}

resource "aws_ecs_task_definition" "nexus" {
  family       = "nexus"
  network_mode = "host"

  volume {
    name      = "nexus-data"
    host_path = "/opt/mount1/nexus"
  }

  volume {
    name      = "consul_config"
    host_path = "/opt/consul/conf"
  }

  container_definitions = <<DEFINITION
	[
        ${data.template_file.consul_agent.rendered},
        ${data.template_file.collectd-nexus.rendered},
        ${data.template_file.nexus.rendered}
	]
    DEFINITION
}

resource "aws_security_group" "nexus" {
  name = "nexus"

  description = "nexus security group"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.admin_cidrs}"
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "nexus-${var.product}-${var.environment}"
    Product   = "${var.product}"
    Environment = "${var.environment}"
    Layer       = "nexus"
  }
}
