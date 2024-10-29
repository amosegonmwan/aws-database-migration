variable "db-username" {
  type    = string
  default = "admin"
}

variable "db-password" {
  type      = string
  default   = "admin123"
  sensitive = true
}