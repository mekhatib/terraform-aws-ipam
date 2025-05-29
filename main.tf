data "aws_region" "current" {}

# 1. Create IPAM
resource "aws_vpc_ipam" "main" {
  description = "${var.project_name} IPAM"

  operating_regions {
    region_name = data.aws_region.current.name
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ipam"
  })
}

# 2. Create Parent Pool
resource "aws_vpc_ipam_pool" "main" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id
  description    = "${var.project_name} main pool"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ipam-pool"
    Type = "parent"
  })
}

# 3. Provision a CIDR block into the parent pool
resource "aws_vpc_ipam_pool_cidr" "main" {
  ipam_pool_id = aws_vpc_ipam_pool.main.id
  cidr         = var.ipam_pool_cidr # Example: "10.0.0.0/8"
}

# 4. Create VPC Pool (child of main pool)
resource "aws_vpc_ipam_pool" "vpc" {
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.main.id
  locale              = data.aws_region.current.name
  description         = "${var.project_name} VPC pool"

  allocation_default_netmask_length = 27
  allocation_min_netmask_length     = 16
  allocation_max_netmask_length     = 28

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc-pool"
    Type = "vpc"
  })
}

# 5. Allocate CIDR from parent pool
resource "aws_vpc_ipam_pool_cidr_allocation" "vpc_from_parent" {
  ipam_pool_id   = aws_vpc_ipam_pool.main.id
  netmask_length = 16

  depends_on = [aws_vpc_ipam_pool_cidr.main]

  lifecycle {
    create_before_destroy = true
  }
}

# 6. Provision the allocated CIDR into the VPC pool
resource "aws_vpc_ipam_pool_cidr" "vpc" {
  ipam_pool_id = aws_vpc_ipam_pool.vpc.id
  cidr         = aws_vpc_ipam_pool_cidr_allocation.vpc_from_parent.cidr

  depends_on = [
    aws_vpc_ipam_pool_cidr.main,
    aws_vpc_ipam_pool_cidr_allocation.vpc_from_parent
  ]
}
