# Refactor using Count Mega-argument
# use locals block to declare local variables
# locals {
#   public_cidr       = ["10.0.0.0/24", "10.0.1.0/24"]
#   private_cidr      = ["10.0.100.0/24", "10.0.101.0/24"]
#   availability_zone = ["eu-west-2a", "eu-west-2b"]
# }
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE VPC
#-------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "env_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_code}-env-vpc"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE IGW
#-------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "env_vpc_igw" {
  vpc_id = aws_vpc.env_vpc.id

  tags = {
    Name = "${var.env_code}-env-igw"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE PUBLIC SUBNETS
#-------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "pub_sub" {
  count = length(local.public_cidr)

  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = local.public_cidr[count.index]
  availability_zone = local.availability_zone[count.index]

  tags = {
    Name = "${var.env_code}-pub-sub${count.index}"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE PRIVATE SUBNETS
#-------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "prt_sub" {
  count = length(local.private_cidr)

  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = local.private_cidr[count.index]
  availability_zone = local.availability_zone[count.index]

  tags = {
    Name = "${var.env_code}-prt-sub${count.index}"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE ELASTIC IPs
#-------------------------------------------------------------------------------------------------------------------
resource "aws_eip" "eip" {
  count = length(local.public_cidr)

  vpc = true

  tags = {
    Name = "${var.env_code}-eip${count.index}"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE NAT GATEWAYS
#-------------------------------------------------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gateway" {
  count = length(local.public_cidr)

  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.pub_sub[count.index].id

  tags = {
    Name = "${var.env_code}-nat-gtw${count.index}"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.env_vpc_igw]
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE ROUTE TABLE PUBLIC
#-------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "pub_rtbl" {
  vpc_id = aws_vpc.env_vpc.id
  # route traffic from public route table to internet via the Internet gateway (IGW)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.env_vpc_igw.id
  }

  tags = {
    Name = "${var.env_code}-public-rtbl"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE PRIVATE ROUTE TABLES 
#-------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "prt_rtbl" {
  count = length(local.private_cidr)

  vpc_id = aws_vpc.env_vpc.id
  # route traffic from priavte route table to internet via the Nat gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private-rtbl${count.index}"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# ROUTE TABLE ASSOCIATIONS
#-------------------------------------------------------------------------------------------------------------------
#public subnet association to public route table
resource "aws_route_table_association" "pub_rtbl_association" {
  count          = length(local.public_cidr)
  subnet_id      = aws_subnet.pub_sub[count.index].id
  route_table_id = aws_route_table.pub_rtbl.id
}
#Private subnets association to  private route tables
resource "aws_route_table_association" "prt_rtbl_association" {
  count          = length(local.private_cidr)
  subnet_id      = aws_subnet.prt_sub[count.index].id
  route_table_id = aws_route_table.prt_rtbl[count.index].id
}





