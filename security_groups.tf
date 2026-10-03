resource "aws_security_group" "sg_ec2" {
  name        = "security_group_ec2"
  description = "Liberar portas HTTP e SSH"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-ec2-simples"
  }
}

resource "aws_security_group" "sg_rds" {
  name        = "rds-simples-sg"
  description = "Liberar porta MySQL apenas para o Security Group da EC2"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ec2.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-rds-simples"
  }
}