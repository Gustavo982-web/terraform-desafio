variable "db_username" {
  type        = string
  default     = "admin_user"
}

variable "db_password" {
  type        = string
  sensitive   = true 
}