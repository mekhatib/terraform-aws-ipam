# IPAM
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

# IPAM Pool - Top Level (Parent Pool)
resource "aws_vpc_ipam_pool" "main" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id
  description    = "${var.project_name} main pool"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ipam-pool"
      Type = "parent"
    }
  )
}

# IPAM Pool CIDR - Parent Pool
resource "aws_vpc_ipam_pool_cidr" "main" {
  ipam_pool_id = aws_vpc_ipam_pool.main.id
  cidr         = var.ipam_pool_cidr
}

# IPAM Pool - VPC Pool (Child of Main)
# This pool will be used for BOTH VPC and subnet allocations
resource "aws_vpc_ipam_pool" "vpc" {
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.main.id
  description         = "${var.project_name} VPC pool"
  locale              = data.aws_region.current.name

  # Allow subnet allocation from this pool
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
}

# IPAM Pool CIDR for VPC - Allocate specific range
resource "aws_vpc_ipam_pool_cidr_allocation" "vpc" {
  ipam_pool_id   = aws_vpc_ipam_pool.main.id
  netmask_length = 16

  depends_on = [aws_vpc_ipam_pool_cidr.main]

  lifecycle {
    create_before_destroy = true
  }
}


# Provision the allocated CIDR to the VPC pool
resource "aws_vpc_ipam_pool_cidr" "vpc" {
  ipam_pool_id = aws_vpc_ipam_pool.vpc.id
  cidr         = aws_vpc_ipam_pool_cidr_allocation.vpc.cidr

  depends_on = [
    aws_vpc_ipam_pool_cidr.main,
    aws_vpc_ipam_pool_cidr_allocation.vpc
  ]
}

data "aws_region" "current" {}
