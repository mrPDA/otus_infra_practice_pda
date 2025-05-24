variable "subnet_id" {
  description = "ID подсети (определяет также зону размещения ВМ)"
  type        = string
}

variable "service_account_id" {
  description = "ID сервисного аккаунта с правами storage.admin"
  type        = string
}

variable "access_key" {
  description = "S3 access key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "S3 secret key"
  type        = string
  sensitive   = true
}

variable "target_bucket" {
  description = "Имя целевого S3-бакета"
  type        = string
}

variable "public_key_path" {
  default     = "~/.ssh/id_rsa.pub"
  description = "Путь к публичному ключу для SSH"
}

variable "private_key_path" {
  default     = "~/.ssh/id_rsa"
  description = "Путь к приватному ключу для SSH"
}

variable "bucket_dependency" {
  description = "Зависимость от IAM или бакета, чтобы избежать гонки"
}