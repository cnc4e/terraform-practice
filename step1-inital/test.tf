terraform {
  required_providers {
    aws = {
      version = ">= 6.6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "tf_test" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "tf-test"
  }
}
