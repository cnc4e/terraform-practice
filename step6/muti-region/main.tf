resource "aws_vpc" "us-east-1" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "us-east-2" {
  provider   = aws.us-east-2
  cidr_block = "10.1.0.0/16"
}