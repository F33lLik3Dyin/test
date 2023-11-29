output "bastion_security_group_id" {
  description = "value of bastion security group id."
  value       = aws_security_group.main.id
}