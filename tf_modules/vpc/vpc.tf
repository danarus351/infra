resource "aws_vpc" "ecs_vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostname
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = var.vpc_name
  }

}

resource "aws_subnet" "public_subnet" {
  for_each                = var.public_azs
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = each.value
  availability_zone       = "${var.region}${each.key}"
  map_public_ip_on_launch = true
  tags = {
    Name                     = "public-subnet-${each.key}"
    "kubernetes.io/role/elb" = 1

  }
}

resource "aws_subnet" "private_subnet" {
  for_each                = var.private_azs
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = each.value
  availability_zone       = "${var.region}${each.key}"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-${each.key}"
  }
}



resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags = {
    Name = "ecs_igw"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet["a"].id

  tags = {
    Name = "nat-gw"
  }
  depends_on = [aws_internet_gateway.ecs_igw]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ecs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip-ecs"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ecs_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-rt"
  }
}


resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}
