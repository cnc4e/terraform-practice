resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = var.dev ? true : false
  enable_dns_hostnames = var.dev ? true : false
}

## countの場合
# resource "aws_subnet" "conditional_count" {
#   count = var.dev ? 1 : 0

#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet-cidr
# }

# resource "aws_subnet" "conditional_count_loop" {
#   count = var.dev ? length(var.subnet-cidrs) : 0

#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet-cidrs[count.index]
# }

## for_eachの場合
# resource "aws_subnet" "conditional_foreach" {
#   for_each = var.dev ? { dummy = "dummy" } : {}

#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet-cidr
# }

resource "aws_subnet" "conditional_foreach_loop" {
  for_each = var.dev ? toset(var.subnet-cidrs) : toset([])

  vpc_id     = aws_vpc.main.id
  cidr_block = each.key
}