output "alb_dns_name" {
  description = "URL publica para acessar a aplicacao atraves do Load Balancer"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "Endpoint interno de conexao do RDS MySQL"
  value       = aws_db_instance.banco-cosmos.address
}