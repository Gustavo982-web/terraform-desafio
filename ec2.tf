resource "aws_instance" "meu_servidor" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.publica.id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  tags = {
    Name = "minha-primeira-ec2 via terraform"
  }
}