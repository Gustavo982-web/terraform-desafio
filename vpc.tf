resource "aws_vpc" "minha_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-simples"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.minha_vpc.id

  tags = {
    Name = "igw-simples"
  }
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.minha_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-publica"
  }
}

resource "aws_subnet" "privada" {
    vpc_id = aws_vpc.minha_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
      Name= "Subnet Privada"
    }
  
}

resource "aws_route_table" "rota_publica" {
  vpc_id = aws_vpc.minha_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-publica"
  }
}

resource "aws_route_table_association" "associacao_publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.rota_publica.id
}