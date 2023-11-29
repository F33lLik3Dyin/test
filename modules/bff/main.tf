locals {
  lb_name                                         = "${var.service}-${var.environment}-${var.target}bff-lb"
  lb_security_group_name                          = "${var.product}-${var.service}-${var.environment}-${var.target}bff-lb-sg"
  lb_target_group_name                            = "${var.service}-${var.environment}-${var.target}bff-tg"
  ecs_cluster_name                                = "${var.product}-${var.service}-${var.environment}-${var.target}bff-cluster"
  ecs_service_name                                = "${var.product}-${var.service}-${var.environment}-${var.target}bff-service"
  ecs_service_security_group_name                 = "${var.product}-${var.service}-${var.environment}-${var.target}bff-ecs-service-sg"
  ecs_task_definition_name                        = "${var.product}-${var.service}-${var.environment}-${var.target}bff-task-definition"
  ecs_task_role_name                              = "${var.product}-${var.service}-${var.environment}-${var.target}bff-task-role"
  ecs_task_execution_role_name                    = "${var.product}-${var.service}-${var.environment}-${var.target}bff-task-execution-role"
  ecr_app_repository_name                         = "${var.product}-${var.service}-${var.environment}-${var.target}bff-app-repository"
  ecs_app_container_difinition_awslogs_group_name = "/${var.product}/${var.service}/${var.environment}/${var.target}bff/app"
  family_and_latest_rivision_task_definiton       = "${aws_ecs_task_definition.main.family}:${max("${aws_ecs_task_definition.main.revision}", "${data.aws_ecs_task_definition.main.revision}")}"
}

resource "aws_lb" "main" {
  name               = local.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.load_balancer_subnets
}

resource "aws_security_group" "lb" {
  name   = local.lb_security_group_name
  vpc_id = var.vpc_id

  ingress {
    description = "allow HTTP access."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "main" {
  name        = local.lb_target_group_name
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.lb_target_group_health_check_path
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name
}

resource "aws_ecs_service" "main" {
  name                              = local.ecs_service_name
  task_definition                   = local.family_and_latest_rivision_task_definiton
  cluster                           = aws_ecs_cluster.main.id
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 240

  network_configuration {
    subnets         = var.ecs_service_subnets
    security_groups = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "app"
    container_port   = 80
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = local.ecs_task_definition_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  container_definitions = templatefile("${path.module}/templates/container-definitions-bff-service-template.json.tftpl", {
    container_name     = "app",
    awslogs_group_name = local.ecs_app_container_difinition_awslogs_group_name
  })

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_iam_role" "task_execution_role" {
  name = local.ecs_task_execution_role_name

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_role" "task_role" {
  name = local.ecs_task_role_name

  inline_policy {
    name   = "ECSTaskRolePolicyForBFF"
    policy = data.aws_iam_policy_document.ecs_task_role_inline_policy.json
  }

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_security_group" "ecs_service" {
  name   = local.ecs_service_security_group_name
  vpc_id = var.vpc_id

  ingress {
    description     = "allow HTTP access."
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "main" {
  name                 = local.ecr_app_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = file("${path.module}/files/ecr-lifecycle-policy.json")
}