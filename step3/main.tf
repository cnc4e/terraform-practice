resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
}

# resource "aws_subnet" "count" {
#   count = length(var.subnet-cidrs)

#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet-cidrs[count.index]
# }

resource "aws_subnet" "foreach" {
  for_each = toset(var.subnet-cidrs)

  vpc_id     = aws_vpc.main.id
  cidr_block = each.key
}

resource "aws_security_group" "dynamic" {
  name        = "dynamic-test"
  description = "Dynamic Test"
  vpc_id      = aws_vpc.main.id

  # dynamic "ingress" {
  #   for_each = toset(var.sg-allow-cidrs)
  #   content{
  #     description      = "TLS from VPC"
  #     from_port        = 443
  #     to_port          = 443
  #     protocol         = "tcp"
  #     cidr_blocks      = [ingress.key]    
  #   }
  # }

  dynamic "ingress" {
    for_each = var.sg-ingress-rulus
    content {
      description = "TLS from VPC"
      from_port   = 443
      to_port     = 443
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.key]
    }
  }
}