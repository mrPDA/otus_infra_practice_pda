terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

resource "yandex_iam_service_account" "admin_sa" {
  name        = var.admin_sa_name
  description = "Service account with full permissions for Terraform"
}

resource "yandex_resourcemanager_folder_iam_member" "admin_sa_roles" {
  for_each = toset([
    "resourcemanager.folder.editor",
    "iam.serviceAccounts.admin",
    "storage.admin",
    "compute.admin",
    "vpc.admin"
  ])
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.admin_sa.id}"
}