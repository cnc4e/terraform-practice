output "dynamic-sgid" {
  value = aws_security_group.dynamic.id
}

output "subnets" {
  value = [for key, value in aws_subnet.foreach : value.id]
}