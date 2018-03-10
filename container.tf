data "template_file" "consul_agent" {
  template = "${file("files/consul-agent.tpl")}"

  vars {
    nameTag = "${var.product}-${var.environment}"
  }
}
