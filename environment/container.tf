data "template_file" "consul_agent" {
  template = "${file("${path.module}/files/consul-agent.tpl")}"

  vars {
    nameTag = "${local.product}-${local.environment}"
    consul_docker_tag = "${var.consul_docker_tag}"
  }
}
