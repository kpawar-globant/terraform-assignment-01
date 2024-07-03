
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  len_ng     = var.nat_gateway_enabled ? (var.nat_gateway_per_az ? length(var.az_list) : 1) : 0
  len_pub_rt = var.multiple_public_route_table ? length(var.public_subnet_cidr) : 1
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    name = var.vpc_name
  }
}

# Create private subnets based on private subnet cidr list provided
resource "aws_subnet" "private-sub" {
  vpc_id = aws_vpc.main.id

  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = length(var.az_list) > 0 ? element(var.az_list, count.index) : null

  count = length(var.private_subnet_cidr)
}

# Public Subnet
resource "aws_subnet" "public-sub" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidr, "${count.index}")
  availability_zone = length(var.az_list) > 0 ? element(var.az_list, count.index) : null

  count = length(var.public_subnet_cidr)
}

# Route table for public subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-vpc-ig.id
  }

  route {
    cidr_block = element(var.public_subnet_cidr, count.index)
    gateway_id = "local"
  }

  count = local.len_pub_rt
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = element(var.private_subnet_cidr, count.index)
    gateway_id = "local"
  }

  count = length(var.private_subnet_cidr)
}

# route for nat gateway based on number of nat gateway
resource "aws_route" "rt_nat_gateway" {
  count                  = var.nat_gateway_enabled ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidr)) : 0
  route_table_id         = aws_route_table.private-rt[count.index].id
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.main-vpc-nat[0].id : aws_nat_gateway.main-vpc-nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
}

# Public route table association
resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-sub[count.index].id
  route_table_id = local.len_pub_rt > 1 ? aws_route_table.public-rt[count.index].id : aws_route_table.public-rt[0].id
  count          = length(aws_subnet.public-sub)
}

# private route table association
resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.private-sub[count.index].id
  route_table_id = aws_route_table.private-rt[count.index].id
  count          = length(var.private_subnet_cidr)
}

# Create internet gateway
resource "aws_internet_gateway" "main-vpc-ig" {
  vpc_id = aws_vpc.main.id
}

# Creating elastic IP for NAT gateway
resource "aws_eip" "eip-nat" {
  domain = "vpc"
  count  = local.len_ng
}

# Create Nat Gateway(s)
resource "aws_nat_gateway" "main-vpc-nat" {
  allocation_id = aws_eip.eip-nat[count.index].id
  subnet_id     = element(var.public_subnet_cidr, count.index)

  depends_on = [aws_internet_gateway.main-vpc-ig]
  count      = local.len_ng
}

