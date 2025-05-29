variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ipam_pool_cidr" {
  description = "Main IPAM pool CIDR block"
  type        = string
  #default     = "10.0.0.0/8"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
