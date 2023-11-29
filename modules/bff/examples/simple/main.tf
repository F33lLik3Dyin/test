terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "qb-bff-simple"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.8.0/24", "10.0.9.0/24"]

  enable_nat_gateway = true
}

module "bff" {
  source = "../../"

  service     = "simple"
  environment = "examples"
  target      = "user"

  vpc_id                = module.vpc.vpc_id
  load_balancer_subnets = module.vpc.public_subnets
  ecs_service_subnets   = module.vpc.private_subnets
}