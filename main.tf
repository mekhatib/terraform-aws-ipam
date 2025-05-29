data "aws_region" "current" {}

# IPAM Instance
resource "aws_vpc_ipam" "main" {
  description = "${var.project_name} IPAM"

  operating_regions {
    region_name = data.aws_region.current.name
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ipam"
    }
  )
}

# Parent IPAM Pool
# Child Pool (for VPCs or Subnets)
resource "aws_vpc_ipam_pool" "vpc" {
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.main.id
  locale              = data.aws_region.current.name
  description         = "${var.project_name} VPC pool"
  allocation_default_netmask_length = 27
  allocation_min_netmask_length     = 16
  allocation_max_netmask_length     = 28
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc-pool"
      Type = "vpc"
    }
  )
  depends_on = [aws_vpc_ipam_pool_cidr.main]
}

# Provision CIDR to the Child Pool
resource "aws_vpc_ipam_pool_cidr" "vpc" {
  ipam_pool_id = aws_vpc_ipam_pool.vpc.id
  depends_on   = [aws_vpc_ipam_pool_cidr.main]
}

# Now you can allocate from the child pool
resource "aws_vpc_ipam_pool_cidr_allocation" "vpc_from_parent" {
  ipam_pool_id   = aws_vpc_ipam_pool.vpc.id
  netmask_length = 16
  depends_on     = [aws_vpc_ipam_pool_cidr.vpc]
  lifecycle {
    create_before_destroy = true
  }
}
