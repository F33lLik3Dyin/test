terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.27.0"
    }
  }
}



module "vpc" {
  source  = "./vpc"
  vpc_name = terraform.workspace == "405441993120" ? "STG" : terraform.workspace == "556597556918" ? "DEV" : "Unknown"
  vpc_cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_block  = "10.0.0.0/24"
  private_subnet_cidr_block = "10.0.1.0/24"
}




provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::${terraform.workspace}:role/terraform-test"

  }
}

