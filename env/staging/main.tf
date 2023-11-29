provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${lookup(local.Service_map,terraform.workspace)}:role/terraform-test"
  }
  default_tags {
    tags = {
    #  "Service_map" = {

    #      "405441993120" = "igaku-kokushi"

    #      "556597556918" = "hoken-kokushi" 

    #    }
      # "Service"     = terraform.workspace == "405441993120" ? "igaku-kokushi" : terraform.workspace == "556597556918" ? "hoken-kokushi" 
      "Environment" = "staging"
      "Terraform"   = "true"
    }
  }
}

locals {
  Service_map = {

         "igaku-kokushi" = "405441993120"

         "hoken-kokushi" = "556597556918"

       }
  environment = "stg"
}

module "vpc" {
  source          = "../../modules/vpc"
  environment     = local.environment
  service         = terraform.workspace
  vpc_cidr_block  = "10.0.0.0/16"
  public_subnet_1_cidr_block   = "10.0.1.0/24"
  public_subnet_2_cidr_block   = "10.0.2.0/24"
  private_subnet_1_cidr_block = "10.0.8.0/24"
  private_subnet_2_cidr_block = "10.0.9.0/24"

  enable_nat_gateway = true
  enable_nat_eip = true
}
# FIXME networkモジュール、routingモジュール作成後に差し替えします
# module "vpc" {
#   source = "../../modules/vpc"

#   # name = "stg-qb-${lookup(local.Service_map,terraform.workspace)}"
#   cidr = "10.0.0.0/16"
#   environment = local.environment


#   azs             = ["ap-northeast-1a", "ap-northeast-1c"]
#   public_subnet  = ["10.0.1.0/24"]
#   private_subnet = ["10.0.8.0/24", "10.0.9.0/24"]

#   enable_nat_gateway = true
# }

# module "userbff" {
#   source = "../../modules/bff"

#   service     = lookup(local.Service_map,terraform.workspace)
#   environment = local.environment
#   target      = "user"

#   vpc_id                = module.vpc.vpc_id
#   load_balancer_subnets = module.vpc.public_subnets
#   ecs_service_subnets   = module.vpc.private_subnets

#   lb_target_group_health_check_path = "/actuator/health"
# }

# module "adminbff" {
#   source = "../../modules/bff"

#   service     = lookup(local.Service_map,terraform.workspace)
#   environment = local.environment
#   target      = "admin"

#   vpc_id                = module.vpc.vpc_id
#   load_balancer_subnets = module.vpc.public_subnets
#   ecs_service_subnets   = module.vpc.private_subnets

#   # FIXME adminbffのECSタスクがspring bootに切り替わったらヘルスチェックパスを更新する
#   lb_target_group_health_check_path = "/"
# }

module "database" {
  source = "../../modules/database"

  service     = terraform.workspace
  environment = local.environment

  rds_master_username = "test"
  rds_master_password = "12345678"

  vpc_id                    = module.vpc.vpc_default_id
  rds_cluster_db_subnet_ids =[
                              module.vpc.subnet_private_1_id,
                              module.vpc.subnet_private_2_id,
  ]
  rds_cluster_ingress_security_groups_ids =[ module.bastion.bastion_security_group_id,
  ]
  #  module.userbff.ecs_service_security_group_id,
  # module.adminbff.ecs_service_security_group_id,
  #  module.batch.batch_security_group_id,
    
  
}

# module "batch" {
#   source = "../../modules/batch"

#   service                                             = lookup(local.Service_map,terraform.workspace)
#   environment                                         = local.environment
#   contents_delivery_server_s3_bucket_id               = module.contents_delivery_server.contents_delivery_server_bucket_id
#   contents_delivery_server_cloudfront_distribution_id = module.contents_delivery_server.contents_delivery_server_distribution_id
#   question_image_replication_s3_bucket_id             = module.contents_delivery_server.question_image_replication_bucket_id
#   question_image_resize_s3_bucket_id                  = module.contents_delivery_server.question_image_resize_bucket_id
#   vpc_id                                              = module.vpc.vpc_id
#   private_subnet_ids                                  = module.vpc.private_subnets
# }

module "bastion" {
  source = "../../modules/bastion"

  service     = terraform.workspace
  environment = local.environment

  vpc_id            = module.vpc.vpc_default_id
  bastion_subnet_id = module.vpc.subnet_public_1_id
}

module "redis_cluster" {
  source = "../../modules/redis"
  service     = terraform.workspace
  environment = local.environment
  vpc_id            = module.vpc.vpc_default_id
  redis_cluster_subnet_ids =[
                              module.vpc.subnet_private_1_id,
                              module.vpc.subnet_private_2_id,
  ]
  security_group_ids =[module.redis_cluster.security_group_ids]
  engine_version = "7.0"
  node_type = "cache.t3.small"
  num_cache_nodes = 1
  port = 6379

  
  }