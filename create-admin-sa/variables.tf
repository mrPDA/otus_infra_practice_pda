variable "yc_token" {
  description = "IAM токен для начального провайдера"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "ID облака"
  type        = string
}

variable "folder_id" {
  description = "ID каталога"
  type        = string
}

variable "admin_sa_name" {
  description = "Имя сервисного аккаунта"
  default     = "terraform-admin-sa"
}