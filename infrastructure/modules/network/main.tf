resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.subnet_availability_zone

  tags = {
    Name = "${var.name}-sb-public"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.subnet_availability_zone

  tags = {
    Name = "${var.name}-sb-private"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-rt"
  }
}

resource "aws_route_table_association" "dubovets_rt_associate_public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.main.id
}