
terraform {
  required_version = ">= 1.3.7"

  required_providers {
    aws = {
      version = "= 4.49.0"
      source  = "hashicorp/aws"
    }
  }

  # # 初回実行時は以下をコメントアウト。tf-backendモジュール実行後に以下を追加
  # backend "s3" {
  #   bucket         = "terraform-practice-mori-tfstate"
  #   key            = "terraform-practice-mori/terraform.tfstate"
  #   encrypt        = true
  #   dynamodb_table = "terraform-practice-mori-tfstate-lock"
  #   region         = "ap-northeast-1"
  # }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      pj    = "terraform-practice-mori"
      owner = "mori"
    }
  }
}