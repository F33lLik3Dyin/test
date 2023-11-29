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

variable "vpc_id" {
  description = "value of vpc id"
  type        = string
}

variable "bastion_subnet_id" {
  description = "value of subnet id"
  type        = string
}
