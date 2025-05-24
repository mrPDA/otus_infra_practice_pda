# 🔐 Авторизация провайдера через JSON-ключ сервисного аккаунта
variable "sa_key_file" {
  description = "Путь к JSON-ключу сервисного аккаунта, используемого в Terraform"
  type        = string
  default     = "admin-key.json"
}

# ☁️ Базовая конфигурация облака
variable "cloud_id" {
  description = "ID облака в Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога в Yandex Cloud"
  type        = string
}

# 👤 Сервисный аккаунт, создаваемый для управления бакетом
variable "service_account_name" {
  description = "Имя создаваемого сервисного аккаунта для доступа к Object Storage"
  default     = "s3-public-bucket-sa"
}

# 🪣 Имя бакета, которое будет дополнено folder_id для глобальной уникальности
variable "bucket_name" {
  description = "Имя создаваемого бакета (будет дополнено folder_id)"
  default     = "otus-bucket-copy"
}

# 🌐 Сеть — подсеть, из которой будет взята зона размещения ВМ
variable "subnet_id" {
  description = "ID существующей подсети в нужной зоне (определяет зону ВМ)"
  type        = string
}

# 🔐 SSH-ключи для подключения к временной ВМ
variable "public_key_path" {
  description = "Путь к публичному SSH-ключу"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Путь к приватному SSH-ключу"
  default     = "~/.ssh/id_rsa"
}