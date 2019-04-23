output "aws_route53_environment_zone_id" {
  value = aws_route53_zone.environment.zone_id
}

output "aws_lb_listener_default_arn" {
  value = aws_alb_listener.default.arn
}

output "aws_alb_default_dns_name" {
  value = aws_alb.default.dns_name
}

output "vpc_id" {
  value = aws_vpc.default.id
}

output "az1_availability_zone" {
  value = var.availability_zone_1
}

output "az1_subnet_id" {
  value = aws_subnet.av1.id
}

output "az2_availability_zone" {
  value = var.availability_zone_2
}

output "az2_subnet_id" {
  value = aws_subnet.av2.id
}

