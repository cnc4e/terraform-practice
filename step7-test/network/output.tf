output "vpc-id" {
  value = aws_vpc.main.id
}

output "subnet-id" {
  value = aws_subnet.private.id
}
