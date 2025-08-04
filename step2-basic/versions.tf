terraform {
  required_version = "= 1.12.2"

  required_providers {
    aws = {
      version = ">= 6.6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Env   = "terraform-practice"
      Owner = "my_name"
    }
  }
}
