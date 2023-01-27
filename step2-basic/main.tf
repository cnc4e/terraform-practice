resource "aws_vpc" "tf_test" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "tf-test"
  }
}

resource "aws_subnet" "tf_test" {
  vpc_id     = aws_vpc.tf_test.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "tf-test"
  }
}