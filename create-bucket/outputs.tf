########################################
#               OUTPUTS                #
########################################

output "bucket_name" {
  description = "Имя созданного S3-бакета"
  value       = yandex_storage_bucket.public_bucket.bucket
}

output "bucket_url" {
  description = "Публичная ссылка на корень бакета"
  value       = "https://${yandex_storage_bucket.public_bucket.bucket}.storage.yandexcloud.net"
}

output "example_object_url" {
  description = "Примерная публичная ссылка на файл (если известно имя)"
  value       = "https://${yandex_storage_bucket.public_bucket.bucket}.storage.yandexcloud.net/sample.csv"
}

output "s3_sync_proxy_ip" {
  description = "Публичный IP временной ВМ для копирования через s3cmd"
  value       = module.s3_sync_proxy.vm_public_ip
}

output "access_key" {
  value = yandex_iam_service_account_static_access_key.script_s3_key.access_key
}

output "secret_key" {
  value = yandex_iam_service_account_static_access_key.script_s3_key.secret_key
  sensitive = true
}