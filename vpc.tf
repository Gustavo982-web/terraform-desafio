resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-desafio"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-desafio"
  }
}

resource "aws_subnet" "publica_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-publica-a"
  }
}

resource "aws_subnet" "publica_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-publica-b"
  }
}

resource "aws_subnet" "privada_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-privada-a"
  }
}

resource "aws_subnet" "privada_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-privada-b"
  }
}

resource "aws_route_table" "rota_publica" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "rt-publica"
  }
}

resource "aws_route_table_association" "assoc_publica_a" {
  subnet_id      = aws_subnet.publica_a.id
  route_table_id = aws_route_table.rota_publica.id
}

resource "aws_route_table_association" "assoc_publica_b" {
  subnet_id      = aws_subnet.publica_b.id
  route_table_id = aws_route_table.rota_publica.id
}