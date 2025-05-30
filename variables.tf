variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "ipam_pool_cidr" {
  description = "CIDR block for the main IPAM pool"
  type        = string
  default     = "10.0.0.0/8"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
