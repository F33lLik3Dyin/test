locals {
  bastion_aws_instance_display_name  = "${var.environment}-${var.product}-${var.service}-bastion"
  bastion_iam_instance_profile_name  = "${var.environment}-${var.product}-${var.service}-iam-instance-profile-bastion"
  bastion_iam_role_name              = "${var.environment}-${var.product}-${var.service}-iam-role-bastion"
  bastion_security_group_name        = "${var.environment}-${var.product}-${var.service}-sg-bastion"
  bastion_security_group_description = "bastion security group for ${var.environment} ${var.service} environment."
}

resource "aws_instance" "main" {
  ami                         = "ami-0947c48ae0aaf6781" # Amazon Linux 2023 AMI
  instance_type               = "t2.micro"
  subnet_id                   = var.bastion_subnet_id
  vpc_security_group_ids      = [aws_security_group.main.id]
  iam_instance_profile        = aws_iam_instance_profile.main.name
  associate_public_ip_address = true

  tags = {
    Name = local.bastion_aws_instance_display_name
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo su
              dnf -y localinstall https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
              dnf -y install mysql-community-client
              EOF
}



resource "aws_iam_instance_profile" "main" {
  name = local.bastion_iam_instance_profile_name
  role = aws_iam_role.main.name
}

resource "aws_iam_role" "main" {
  name                = local.bastion_iam_role_name
  assume_role_policy  = data.aws_iam_policy_document.main.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

data "aws_iam_policy_document" "main" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_security_group" "main" {
  name        = local.bastion_security_group_name
  description = local.bastion_security_group_description
  vpc_id      = var.vpc_id

  # ingress {
  #   description = "XXX ip"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["XXX.XXX.XXX.XXX/32"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}