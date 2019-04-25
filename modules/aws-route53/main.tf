resource "aws_route53_record" "environment" {
  count   = "1"
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.context.environment.name
  type    = "NS"
  ttl     = 60

  records = [
    aws_route53_zone.environment.name_servers[0],
    aws_route53_zone.environment.name_servers[1],
    aws_route53_zone.environment.name_servers[2],
    aws_route53_zone.environment.name_servers[3],
  ]
}

resource "aws_route53_zone" "environment" {
  name = "${var.context.environment.name}.${var.context.product.root_domain_name}"

  tags = {
    Environment = var.context.environment.name
  }
}

data "aws_route53_zone" "selected" {
  name = "${var.context.product.root_domain_name}."
}

