# redis_cluster/main.tf
variable "product" {
  description = "The name of product."
  type        = string
  default     = "qb"
}

variable "service" {
  description = "The name of service that problem pratcice service."
  type        = string
}

variable "environment" {
  description = "The name of environment."
  type        = string
}

variable "vpc_id" {
  description = "value of the vpc id."
  type        = string
}

# variable "cluster_id" {
#   description = "Redis cluster ID"
# }

variable "engine_version" {
  description = "Redis engine version"
}

variable "node_type" {
  description = "Redis node type"
  default     = "cache.t3.small"
}

variable "port" {
  description = "Redis port"
  
}
variable "redis_cluster_subnet_ids" {
  description = "list of subnet id for rds cluster."
  type        = list(string)
}

variable "security_group_ids" {
  description = "list of subnet id for rds cluster."
  type        = list(string)
}
variable "num_cache_nodes" { 
}
locals {
  redis_cluster_identifier           = "${var.environment}-${var.product}-${var.service}-redis"
  redis_cluster_security_group_name  = "${var.environment}-${var.product}-${var.service}-redis-sg"
  redis_cluster_subnet_group_name = "${var.environment}-${var.product}-${var.service}-redis-subnet-group"
}





resource "aws_security_group" "redis_sg" {
  name        = local.redis_cluster_security_group_name
  description = "Allow Redis traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.8.0/24"]
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = local.redis_cluster_subnet_group_name
  subnet_ids = var.redis_cluster_subnet_ids
}

# resource "aws_elasticache_cluster" "redis_cluster" {
#   cluster_id           = var.cluster_id
#   engine               = "redis"
#   node_type            = var.node_type
#   num_cache_nodes      = var.num_cache_nodes
#   parameter_group_name = var.parameter_group_name
#   subnet_group_name    = aws_elasticache_subnet_group.example.name
#   security_group_ids   = [aws_security_group.redis_sg.id]

# }

# resource "aws_elasticache_cluster" "redis" {
#   cluster_id           = local.redis_cluster_identifier
#   engine               = "redis"
#   node_type            = "cache.m4.large"
#   num_cache_nodes      = 1
#   parameter_group_name = "default.redis7.cluster.on"
#   engine_version       = "7.0"
#   port                 = 6379
# }


# provider "aws" {
#   region = "AWSのリージョンを指定"
# }

# resource "aws_elasticache_cluster" "redis_cluster" {
#   cluster_id               = "dev-qb-igaku-redis"
#   engine                   = "redis"
#   engine_version           = "7.0"
#   node_type                = "cache.t3.small"
#   port                     = 6379
#   parameter_group_name     = "default"
#   replication_group_id     = "dev-qb-igaku-redis"
#   number_cache_nodes       = 1
#   subnet_group_name        = "redis-private-stg"
#   security_group_ids       = ["セキュリティグループのIDを指定"]

#   at_rest_encryption_enabled   = false
#   transit_encryption_enabled  = false
#   automatic_failover_enabled   = false
#   az_mode                      = "single-az"
#   apply_immediately            = true
#   maintenance_window          = "Sun:00:00-Sun:01:00"

#   lifecycle {
#     prevent_destroy = true
#   }
# }



resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id               = local.redis_cluster_identifier
  engine                   = "redis"
  engine_version           = var.engine_version
  node_type                = var.node_type
  port                     = var.port
 # parameter_group_name     = aws_elasticache_parameter_group.redis_parameter_group.id
 # replication_group_id     = var.cluster_id
  num_cache_nodes          = var.num_cache_nodes
  subnet_group_name        = local.redis_cluster_subnet_group_name
  security_group_ids       = var.security_group_ids

  #at_rest_encryption_enabled   = false
  transit_encryption_enabled  = false
  #automatic_failover_enabled   = false
  az_mode                      = "single-az"
  apply_immediately            = true
  maintenance_window          = "Sun:00:00-Sun:01:00"

 # lifecycle {
  #  prevent_destroy = true
  #}
}

output "security_group_ids" {
  value = aws_security_group.redis_sg.id
}