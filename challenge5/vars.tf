//don't do this:
variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
  default     = "changeme"
}

// Don't do this:
variable "user_name" {
  description = "RDS username"
  type        = string
  sensitive   = true
  default     = "root"
}
