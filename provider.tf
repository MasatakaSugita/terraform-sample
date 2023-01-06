#----------------------------
# Provider設定
#----------------------------
provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-sample-sugita"
    key     = "terraform-sample.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}