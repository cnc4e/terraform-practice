resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
}

# countの場合
# resource "aws_subnet" "count" {
#   count = length(var.subnet-cidrs)

#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet-cidrs[count.index]
# }

# for_eachの場合
resource "aws_subnet" "foreach" {
  for_each = toset(var.subnet-cidrs)

  vpc_id     = aws_vpc.main.id
  cidr_block = each.key
}
