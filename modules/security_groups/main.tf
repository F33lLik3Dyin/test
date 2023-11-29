variable "service" {
  type = string
}
variable "environment" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}

# resource "aws_security_group" "bastion_security_group" {
#   description = "Security group for Bastion Instance"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "SSH Claves VPN"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["183.77.252.82/32"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.environment}-bastion-ec2-instance-tf"
#   }
# }

resource "aws_security_group" "db_security_group" {
  name        = "${var.environment}-${var.service}-db-security-group-tf"
  description = "Access to the RDS instances from the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.service}-db-security-group-tf"
  }
}
