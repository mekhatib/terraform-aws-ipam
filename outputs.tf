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
