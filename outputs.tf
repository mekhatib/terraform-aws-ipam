output "ipam_id" {
  description = "The ID of the IPAM"
  value       = aws_vpc_ipam.main.id
}

output "main_pool_id" {
  description = "The ID of the main IPAM pool"
  value       = aws_vpc_ipam_pool.main.id
}

output "vpc_ipam_pool_id" {
  description = "The ID of the VPC IPAM pool"
  value       = aws_vpc_ipam_pool.vpc.id
}

output "vpc_ipam_pool_cidr" {
  description = "The CIDR block allocated to the VPC pool"
  value       = aws_vpc_ipam_pool_cidr.vpc.cidr
}

output "main_pool_cidr" {
  description = "The CIDR block of the main pool"
  value       = aws_vpc_ipam_pool_cidr.main.cidr
}
