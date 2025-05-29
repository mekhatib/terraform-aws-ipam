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

# Provision CIDR to the Parent Pool
resource "aws_vpc_ipam_pool_cidr" "main" {
  ipam_pool_id = aws_vpc_ipam_pool.main.id
  cidr         = var.ipam_pool_cidr # Example: "10.0.0.0/8"
}

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
