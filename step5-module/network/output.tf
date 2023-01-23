output "vpc-id" {
  value = aws_vpc.main.id
}

output "subnet-ids" {
  value = [for key, value in aws_subnet.foreach : value.id]
}