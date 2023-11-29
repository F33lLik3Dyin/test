# 共通
variable "service" {
  type = string
}
variable "environment" {
  type = string
}
variable "subnet_private_1_id" {
  type = string
}
variable "subnet_private_2_id" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_user" {
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "vpc_security_group_id" {
  type = string
}

locals {
  // インスタンスを配置するazの指定
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
  // 自動バックアップ世代数の指定
  backup_retention_period = 7
  // Aurora Serverless v2の最小容量の指定
  min_capacity = 0.5
  // Aurora Serverless v2の最大容量の指定
  max_capacity = 1
  // instance数の指定
  rds_num_nodes = 1
}

resource "aws_rds_cluster_parameter_group" "default" {
  name   = "${var.service}-${var.environment}-cluster-parameter-group-tf"
  family = "aurora-mysql8.0"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}

resource "aws_db_parameter_group" "default" {
  name   = "${var.environment}-${var.service}-db-parameter-group-tf"
  family = "aurora-mysql8.0"
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.environment}-${var.service}-db-subnet-group-tf"
  subnet_ids = ["${var.subnet_private_1_id}", "${var.subnet_private_2_id}"]
}

resource "aws_rds_cluster" "default" {
  cluster_identifier              = "${var.environment}-${var.service}-db-cluster"
  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned"
  engine_version                  = "8.0.mysql_aurora.3.02.0"
  availability_zones              = local.availability_zones
  db_subnet_group_name            = aws_db_subnet_group.default.name
  database_name                   = var.db_name
  master_username                 = var.db_user
  master_password                 = var.db_password
  backtrack_window                = 0
  backup_retention_period         = local.backup_retention_period
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  port                            = 3306
  skip_final_snapshot             = true #true->false
  storage_encrypted               = true
  vpc_security_group_ids          = ["${var.vpc_security_group_id}"]

  // aurora serverless v2のmax/minの容量を設定
  serverlessv2_scaling_configuration {
    min_capacity = local.min_capacity
    max_capacity = local.max_capacity
  }

  deletion_protection       = false #false->true
  apply_immediately         = true
  final_snapshot_identifier = "${var.environment}-${var.service}-final-snapshot"

  lifecycle {
    ignore_changes = [
      master_password,
      availability_zones
    ]
  }
}

resource "aws_rds_cluster_instance" "instance" {
  // instance数を設定
  count = local.rds_num_nodes
  // instance数に応じて順次az設定
  availability_zone  = local.availability_zones[count.index % length(local.availability_zones)]
  cluster_identifier = aws_rds_cluster.default.id
  // instance数に応じて01、02とinstance名を連番に設定
  identifier     = "${var.environment}-${var.service}-db-instance-${format("%02d", count.index + 1)}"
  engine         = aws_rds_cluster.default.engine
  engine_version = aws_rds_cluster.default.engine_version
  // serverlessを指定
  instance_class             = "db.serverless"
  db_subnet_group_name       = aws_db_subnet_group.default.name
  db_parameter_group_name    = aws_db_parameter_group.default.name
  publicly_accessible        = false
  auto_minor_version_upgrade = false
}