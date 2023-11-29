variable "environment" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "vpc_security_group_id" {
  type = string
}


#----------------------------------------------------------------
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.environment}-key-pair"
  public_key = file("${path.module}/key_pair/${var.environment}_id_rsa.pub")
}

resource "aws_instance" "bastion" {
  ami                    = "ami-08a8688fb7eacb171"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.id
  subnet_id              = var.subnet_id
  vpc_security_group_ids = ["${var.vpc_security_group_id}"]
  tags = {
    Name = "bastion-server-${var.environment}-tf"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y install mysql
              EOF
}

