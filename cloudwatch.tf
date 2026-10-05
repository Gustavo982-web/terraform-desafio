resource "aws_sns_topic" "alertas_infra" {
  name = "topico-alertas-infraestrutura"
}

resource "aws_sns_topic_subscription" "email_alerta" {
  topic_arn = aws_sns_topic.alertas_infra.arn
  protocol  = "email"
  endpoint  = var.email_alertas
}

resource "aws_cloudwatch_metric_alarm" "conexoes_altas_rds" {
  alarm_name          = "alarme-conexoes-altas-rds"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "Alerta de numero elevado de conexoes simultaneas no banco RDS."
  alarm_actions       = [aws_sns_topic.alertas_infra.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.banco-cosmos.id
  }
}

resource "aws_cloudwatch_metric_alarm" "erros_5xx_alb" {
  alarm_name          = "alarme-erros-5xx-aplicacao"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Dispara quando o ALB detecta erros internos (5XX) na aplicacao Node.js."
  alarm_actions       = [aws_sns_topic.alertas_infra.arn]

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}