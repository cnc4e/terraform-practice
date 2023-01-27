data "aws_ssm_parameter" "al2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "this" {
  ami             = data.aws_ssm_parameter.al2.value
  instance_type   = var.type
  subnet_id       = var.subnet-id
  security_groups = [aws_security_group.this.id]

  root_block_device {
    encrypted = var.app == "front" ? true : false
  }

  tags = {
    "Name" = "${var.pj}-${var.app}"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.pj}-${var.app}-ec2-sg"
  description = "${var.pj}-${var.app} ec2 sg"
  vpc_id      = var.vpc-id

  dynamic "ingress" {
    for_each = toset(var.allow-tcp-ports)
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = [var.allow-access-cidr]
    }
  }

  tags = {
    "Name" = "${var.pj}-${var.app}-ec2-sg"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = var.app == "back" ? { app = "back" } : {}
  bucket   = "${var.pj}-${var.app}-bucket"

  tags = {
    "Name" = "${var.pj}-${var.app}-bucket"
  }
}
