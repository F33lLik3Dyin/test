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

variable "basic_authentication" {
  description = "value of basic authentication. If enabled is ture, basic authentication is enabled."
  type = object({
    enabled  = bool
    user_id  = string
    password = string
  })
  default = {
    enabled  = false
    user_id  = null
    password = null
  }
  sensitive = true

  validation {
    condition     = var.basic_authentication.user_id != null && var.basic_authentication.password != null
    error_message = "the basic_authentication.value_id and basic_authentication.password value is invalid. the basic_authentication.value_id and basic_authentication.password value must be string."
  }
}

variable "cloudfront_bff_lb_origin_domain_name" {
  description = "DNS domain name of the bff load balancer"
  type        = string
  default     = ""
}