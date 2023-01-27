terraform {
  required_providers {
    aws = {
      version = ">= 4.49.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      Pj    = "tfpractice"
      Owner = "mori"
      Steps = "step7"
    }
  }
}
