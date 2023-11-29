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

variable "rds_master_username" {
  description = "value of the rds master username."
  type        = string
  sensitive   = true
}

variable "rds_master_password" {
  description = "value of the rds master password."
  type        = string
  sensitive   = true
}


variable "vpc_id" {
  description = "value of the vpc id."
  type        = string
}

variable "rds_cluster_ingress_security_groups_ids" {
  description = "list of security group id for rds cluster access."
  type        = list(string)
}

variable "rds_cluster_db_subnet_ids" {
  description = "list of subnet id for rds cluster."
  type        = list(string)
}