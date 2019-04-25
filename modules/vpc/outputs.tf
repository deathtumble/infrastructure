output "vpc_id" {
  value = aws_vpc.default.id
}

output "az1_availability_zone" {
  value = var.context.vpcs[var.vpc_name].azs["1st"].name
}

output "az1_subnet_id" {
  value = aws_subnet.av1.id
}

output "az2_availability_zone" {
  value = var.context.vpcs[var.vpc_name].azs["2nd"].name
}

output "az2_subnet_id" {
  value = aws_subnet.av2.id
}

output "subnets" {
  value = [aws_subnet.av2.id, aws_subnet.av1.id]
}