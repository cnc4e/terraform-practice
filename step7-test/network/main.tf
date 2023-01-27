resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr

  tags = {
    "Name" = "${var.pj}-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet-cidr

  tags = {
    "Name" = "${var.pj}-private"
  }
}
