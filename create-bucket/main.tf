########################################
#            PROVIDER SETUP           #
########################################

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"   # ← это важно!
      version = "~> 0.141.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "yandex" {
  service_account_key_file = var.sa_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

#######################################
# 1. Сервисный аккаунт
########################################

resource "yandex_iam_service_account" "s3_sa" {
  name        = var.service_account_name
  description = "Service account for managing S3 bucket"
}

resource "yandex_resourcemanager_folder_iam_member" "s3_sa_roles" {
  for_each = toset([
    "storage.admin",
    "storage.uploader",
    "storage.viewer"
  ])
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.s3_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "s3_key" {
  service_account_id = yandex_iam_service_account.s3_sa.id
  description        = "S3 static access key"
}

resource "yandex_iam_service_account_static_access_key" "script_s3_key" {
  service_account_id = yandex_iam_service_account.s3_sa.id
  description        = "Static key for S3 copy script"
}

########################################
# 2. Публичный бакет
########################################

resource "yandex_storage_bucket" "public_bucket" {
  bucket        = "${var.bucket_name}-${var.folder_id}"
  access_key    = yandex_iam_service_account_static_access_key.s3_key.access_key
  secret_key    = yandex_iam_service_account_static_access_key.s3_key.secret_key
  force_destroy = true

  anonymous_access_flags {
    read = true
    list = true
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.s3_sa_roles]
}

########################################
# 3. Модуль копирования через временную ВМ
########################################

module "s3_sync_proxy" {
  source             = "./s3-sync-proxy"
  subnet_id          = var.subnet_id
  service_account_id = yandex_iam_service_account.s3_sa.id
  access_key         = yandex_iam_service_account_static_access_key.s3_key.access_key
  secret_key         = yandex_iam_service_account_static_access_key.s3_key.secret_key
  target_bucket      = yandex_storage_bucket.public_bucket.bucket
  bucket_dependency  = yandex_resourcemanager_folder_iam_member.s3_sa_roles
}