output "rds_endpoint" {
  description = "Endpoint de la instancia RDS"
  value       = aws_db_instance.rds_mysql.endpoint
}

output "rds_username" {
  description = "Usuario de la base de datos"
  value       = var.db_username
}

output "rds_db_name" {
  description = "Nombre de la base de datos"
  value       = var.db_name
}

output "connection_string" {
  description = "String de conexión completa"
  value       = "mysql://${var.db_username}:${var.db_password}@${aws_db_instance.rds_mysql.endpoint}/${var.db_name}"
  sensitive   = true
}
