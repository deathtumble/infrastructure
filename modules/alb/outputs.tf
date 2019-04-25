output "aws_lb_listener_default_arn" {
  value = aws_alb_listener.default.arn
}

output "aws_alb_default_dns_name" {
  value = aws_alb.default.dns_name
}

