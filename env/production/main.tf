provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${terraform.workspace}:role/terraform-test"
  }
  default_tags {
    tags = {
      "Environment" = "production"
      "Terraform"   = "true"
    }
  }
}

locals {

  env_map = {

    "405441993120" = "igaku"

    "556597556918" = "hoken"

  }
  environment = "prd"

}



variable "rds_master_username" {
  description = "value of the rds master username."
  type        = string
  default     = "test1"
  sensitive   = true
}

variable "rds_master_password" {
  description = "value of the rds master password."
  type        = string
  default     =  "22222222"
  sensitive   = true
}


# FIXME networkモジュール、routingモジュール作成後に差し替えします
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_name           = lookup(local.env_map, terraform.workspace)
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  private_subnets = ["10.0.8.0/24", "10.0.9.0/24"]
  
  enable_nat_gateway = true
}



module "database" {
  source = "../../modules/database"

  service     = lookup(local.env_map, terraform.workspace)
  environment = local.environment

  rds_master_username = var.rds_master_username
  rds_master_password = var.rds_master_password

  vpc_id                    = module.vpc.vpc_id
  rds_cluster_db_subnet_ids = module.vpc.private_subnets
  rds_cluster_ingress_security_groups_ids = [
    module.bastion.bastion_security_group_id,
  ]
}


module "bastion" {
  source = "../../modules/bastion"

  service     = lookup(local.env_map, terraform.workspace)
  environment = local.environment

  vpc_id            = module.vpc.vpc_id
  bastion_subnet_id = module.vpc.public_subnets[0]
}