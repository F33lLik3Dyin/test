# 共通
variable "product" {
  description = "The name of product."
  type        = string
  default     = "qb"
}
variable "service" {
  type = string
}
variable "environment" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "public_subnet_1_cidr_block" {
  type = string
}
variable "public_subnet_2_cidr_block" {
  type = string
}
variable "private_subnet_1_cidr_block" {
  type = string
}
variable "private_subnet_2_cidr_block" {
  type = string
}
variable "enable_nat_gateway" {
  type    = bool
}

# Elastic IP 변수
variable "enable_nat_eip" {
  type    = bool
}

# --------------------------------
# VPC
resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-vpc"
  }
}

# --------------------------------
# Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-igw"
  }
}

# --------------------------------
# Public
# 1.1 Public Subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_1_cidr_block
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-subnet-pub-1a"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_2_cidr_block
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-subnet-pub-1c"
  }
}

# 2.1 Public Route Table + ルート定義
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-rtb-pub"
  }
}

# 2.2 Public Route TableとPublic Subnetの関連付け
resource "aws_route_table_association" "route_table_association_public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.route_table_public.id
}
resource "aws_route_table_association" "route_table_association_public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.route_table_public.id
}


# --------------------------------
# Private
# 1.1 Private Subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_1_cidr_block
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-subnet-pri-1a"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_2_cidr_block
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.environment}-${var.product}b-${var.service}-subnet-pri-1c"
  }
}

# 2.1 Private Route Table + ルート定義
resource "aws_route_table" "route_table_private_1" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-rtb-pri-1a"
  }
}
resource "aws_route_table" "route_table_private_2" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-rtb-pri-1c"
  }
}
# 2.2 Private Route TableとPrivate Subnetの関連付け
resource "aws_route_table_association" "route_table_association_private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.route_table_private_1.id
}

resource "aws_route_table_association" "route_table_association_private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.route_table_private_2.id
}

# --------------------------------
# Nat gateway
# EIP
resource "aws_eip" "nat_eip_1" {
  vpc = true
  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-eip-1"
  }
}

resource "aws_eip" "nat_eip_2" {
  vpc = true
  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-eip-2"
  }
}

#NAT gateway 作成

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.private_subnet_1.id
  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-ngw-1a"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.private_subnet_2.id
  tags = {
    Name = "${var.environment}-${var.product}-${var.service}-ngw-1c"
  }
}

# resource "aws_network_interface_sg_attachment" "nat_gateway_attachment_1" {
# #  security_group_id    = aws_security_group.nat_sg.id
#   network_interface_id = aws_nat_gateway.nat_gateway_1.id
# }

# resource "aws_network_interface_sg_attachment" "nat_gateway_attachment_2" {
# #  security_group_id    = aws_security_group.nat_sg.id
#   network_interface_id = aws_nat_gateway.nat_gateway_2.id
# }

# # resource "aws_security_group" "nat_sg" {
# #   name        = "${var.environment}-${var.product}-${var.service}-nat-sg"
# #   description = "Security Group for NAT Gateway"
# #   vpc_id      = aws_vpc.default.id

# #   # 추가적인 규칙 및 설정을 여기에 추가할 수 있습니다.
# # }


output "vpc_default_id" {
  value = aws_vpc.default.id
}
output "subnet_public_1_id" {
  value = aws_subnet.public_subnet_1.id
}
output "subnet_public_2_id" {
  value = aws_subnet.public_subnet_2.id
}
output "subnet_private_1_id" {
  value = aws_subnet.private_subnet_1.id
}
output "subnet_private_2_id" {
  value = aws_subnet.private_subnet_2.id
}
