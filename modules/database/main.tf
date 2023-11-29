

locals {
  rds_cluster_identifier           = "${var.environment}-${var.product}-${var.service}-rds-cluster"
  rds_cluster_security_group_name  = "${var.environment}-${var.product}-${var.service}-rds-cluster-sg"
  rds_cluster_db_subnet_group_name = "${var.environment}-${var.product}-${var.service}-db-subnet-group"
  rds_cluster_parameter_group_name = "${var.environment}-${var.product}-${var.service}-rds-cluster-parameter-group"
}

resource "aws_rds_cluster" "main" {
  cluster_identifier              = local.rds_cluster_identifier
  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned"
  engine_version                  = "8.0.mysql_aurora.3.03.1"
  database_name                   = "qb"
  master_username                 = var.rds_master_username
  master_password                 = var.rds_master_password
  availability_zones              = ["ap-northeast-1a", "ap-northeast-1c"]
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.main.id]
  backup_retention_period         = 7
  preferred_backup_window         = "15:00-16:00"         # JST 00:00-01:00
  preferred_maintenance_window    = "sun:17:00-sun:17:30" # JST mon:02:00-mon:02:30
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.id
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  lifecycle {
    ignore_changes = [
      availability_zones
    ]
  }
}

resource "aws_rds_cluster_instance" "writer" {
  cluster_identifier   = aws_rds_cluster.main.cluster_identifier
  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_subnet_group_name = aws_rds_cluster.main.db_subnet_group_name

  availability_zone = "ap-northeast-1a"
}

resource "aws_rds_cluster_instance" "reader" {
  cluster_identifier   = aws_rds_cluster.main.cluster_identifier
  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_subnet_group_name = aws_rds_cluster.main.db_subnet_group_name

  availability_zone = "ap-northeast-1c"
  depends_on        = [aws_rds_cluster_instance.writer]
}

resource "aws_rds_cluster_parameter_group" "main" {
  name        = local.rds_cluster_parameter_group_name
  family      = "aurora-mysql8.0"
  description = "parameter group for rds cluster"

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  # 監査ログを有効
  parameter {
    name  = "server_audit_logging"
    value = "1"
  }

  # 一般ログを有効
  parameter {
    name  = "general_log"
    value = "1"
  }

  # スロークエリログを有効
  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  # ログをCloudWatch Logsに発行
  parameter {
    name  = "log_output"
    value = "FILE"
  }
}

resource "aws_db_subnet_group" "main" {
  name        = local.rds_cluster_db_subnet_group_name
  description = "db subnet group for rds cluster"
  subnet_ids  = var.rds_cluster_db_subnet_ids
}

resource "aws_security_group" "main" {
  name        = local.rds_cluster_security_group_name
  description = "security group for rds cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "allow rds cluster access from security groups"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.rds_cluster_ingress_security_groups_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}