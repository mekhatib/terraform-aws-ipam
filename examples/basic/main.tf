provider "aws" {
  region = var.aws_region
}

module "ipam_example" {
  source = "../../"
  
  environment  = var.environment
  project_name = var.project_name
  
  # Add other required variables based on the module
}

variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "test"
}

variable "project_name" {
  default = "example"
}
