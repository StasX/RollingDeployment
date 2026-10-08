data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.PROJECT_NAME}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.PROJECT_NAME}-igw"
  }
}

resource "aws_subnet" "public_sn" {
  count = 2

  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(
    aws_vpc.vpc.cidr_block,
    8,
    count.index
  )
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.PROJECT_NAME}-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.PROJECT_NAME}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count = 2

  subnet_id      = aws_subnet.public_sn[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "monitoring_sn" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 10)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.PROJECT_NAME}-monitoring"
  }
}

resource "aws_route_table_association" "monitoring_rt_assoc" {
  subnet_id      = aws_subnet.monitoring_sn.id
  route_table_id = aws_route_table.public_rt.id
}
