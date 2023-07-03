#-------------------------------------------------------------------------------------------------------------------
# RESOURCE VPC
#-------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "env_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "env-vpc"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE IGW
#-------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "env_vpc_igw" {
  vpc_id = aws_vpc.env_vpc.id

  tags = {
    Name = "env-vpc-igw"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE PUBLIC SUBNETS
#-------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "pub_sub_01" {
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "pub-sub-01"
  }
}
resource "aws_subnet" "pub_sub_02" {
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "pub-sub-02"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE PRIVATE SUBNETS
#-------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "prt_sub_01" {
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "prt-sub-01"
  }
}
resource "aws_subnet" "prt_sub_02" {
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "prt-sub-02"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE ELASTIC IPs
#-------------------------------------------------------------------------------------------------------------------
resource "aws_eip" "eip_01" {
  vpc = true

  tags = {
    Name = "eip-01"
  }
}
resource "aws_eip" "eip_02" {
  vpc = true

  tags = {
    Name = "eip-02"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE NAT GATEWAYS
#-------------------------------------------------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gateway_01" {
  allocation_id = aws_eip.eip_01.id
  subnet_id     = aws_subnet.pub_sub_01.id

  tags = {
    Name = "nat-gtw-01"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.env_vpc_igw]
}
resource "aws_nat_gateway" "nat_gateway_02" {
  allocation_id = aws_eip.eip_02.id
  subnet_id     = aws_subnet.pub_sub_02.id

  tags = {
    Name = "nat-gtw-02"
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
        Name = "public-rtbl"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# RESOURCE PRIVATE ROUTE TABLES 
#-------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "prt_rtbl_01" {
  vpc_id = aws_vpc.env_vpc.id
  # route traffic from priavte route table to internet via the Nat gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_01.id
  }
    tags = {
        Name = "private-rtbl-01"
    }
}

#SECOND PRIVATE ROUTE TABLE
resource "aws_route_table" "prt_rtbl_02" {
  vpc_id = aws_vpc.env_vpc.id
  # route traffic from priavte route table to internet via the Nat gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_02.id
  }

    tags = {
    Name = "private-rtbl-02"
  }
}
#-------------------------------------------------------------------------------------------------------------------
# ROUTE TABLE ASSOCIATIONS
#-------------------------------------------------------------------------------------------------------------------
#public subnet association to public route table
resource "aws_route_table_association" "pub_rtbl_association_01" {
  subnet_id      = aws_subnet.pub_sub_01.id
  route_table_id = aws_route_table.pub_rtbl.id
}
resource "aws_route_table_association" "pub_rtbl_association_02" {
  subnet_id      = aws_subnet.pub_sub_02.id
  route_table_id = aws_route_table.pub_rtbl.id
}
#Private subnet association to respective private route tables
resource "aws_route_table_association" "prt_rtbl_association_01" {
  subnet_id      = aws_subnet.prt_sub_01.id
  route_table_id = aws_route_table.prt_rtbl_01.id
}

resource "aws_route_table_association" "prt_rtbl_association_02" {
  subnet_id      = aws_subnet.prt_sub_02.id
  route_table_id = aws_route_table.prt_rtbl_02.id
}

