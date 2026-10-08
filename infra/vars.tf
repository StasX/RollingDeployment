# Project configuration
variable "PROJECT_NAME" {
  type        = string
  description = "Project name used for AWS resource naming"
}

# EC2 configuration
variable "MOST_RECENT" {
  type        = bool
  description = "Select the most recent Ubuntu AMI"
  default     = true
}

variable "AMI_ID" {
  type        = string
  description = "Optional explicit AMI ID"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

# Domain configuration
variable "USE_DOMAIN" {
  type        = bool
  description = "Whether to configure a Route 53 application record"
  default     = false
}

variable "DOMAIN_NAME" {
  type        = string
  description = "Existing public Route 53 hosted zone domain"
  default     = ""

  validation {
    condition     = !var.USE_DOMAIN || trimspace(var.DOMAIN_NAME) != ""
    error_message = "DOMAIN_NAME must be provided when USE_DOMAIN is true."
  }
}

# Administrator access
variable "ADMIN_ALLOWED_CIDR" {
  type        = string
  description = "Public IPv4 CIDR allowed to access SSH and Grafana"

  validation {
    condition = (
      can(cidrnetmask(var.ADMIN_ALLOWED_CIDR)) &&
      var.ADMIN_ALLOWED_CIDR != "0.0.0.0/0"
    )
    error_message = "ADMIN_ALLOWED_CIDR must be a valid IPv4 CIDR other than 0.0.0.0/0."
  }
}
