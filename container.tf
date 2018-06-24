data "template_file" "consul_agent" {
  template = "${file("files/consul-agent.tpl")}"

  vars {
    nameTag = "${var.product}-${var.environment}"
    consul_docker_tag = "${var.consul_docker_tag}"
  }
}
