variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "testdb"
}

variable "db_username" {
  description = "Nombre de usuario de la base de datos"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}
