output "vpc_id" {
  value = aws_vpc.tf_test.id
}

output "vpc_arn" {
  value = aws_vpc.tf_test.arn
}

output "subnet" {
  value = aws_subnet.tf_test
}
