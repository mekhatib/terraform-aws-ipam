output "ipam_id" {
  description = "ID of the IPAM"
  value       = aws_vpc_ipam.main.id
}

output "main_pool_id" {
  description = "ID of the main IPAM pool"
  value       = aws_vpc_ipam_pool.main.id
}

output "vpc_pool_id" {
  description = "ID of the VPC IPAM pool"
  value       = aws_vpc_ipam_pool.vpc.id
}

output "allocated_cidr" {
  description = "The allocated CIDR block"
  value       = aws_vpc_ipam_pool_cidr_allocation.vpc_from_parent.cidr
}
