output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.main.dns_name
}

output "ecs_service_security_group_id" {
  description = "value of ecs_service_security_group_id."
  value       = aws_security_group.ecs_service.id
}