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
      Env   = "terraform-practice"
      Owner = "mori"
      Steps = "step3"
    }
  }
}
