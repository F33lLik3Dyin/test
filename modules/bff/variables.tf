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

variable "target" {
  description = "The target using frontend application."
  type        = string
}

variable "vpc_id" {
  description = "The id of vpc."
  type        = string
}

variable "load_balancer_subnets" {
  description = "The subnets to associate with the load balancer for bff application."
  type        = list(string)
}

variable "ecs_service_subnets" {
  description = "The subnets to associate with the ecs service for bff application."
  type        = list(string)
}

variable "lb_target_group_health_check_path" {
  description = "The path of the health check."
  type        = string
  default     = "/"
}