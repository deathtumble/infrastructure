data "template_file" "consul_agent" {
  template = "${file("files/consul-agent.tpl")}"

  vars {
    nameTag = "${var.nameTag}"
  }
}

data "template_file" "collectd" {
  template = "${file("files/collectd.tpl")}"

  vars {
    graphite_prefix = "${var.ecosystem}.${var.environment}.nexus."
  }
}
