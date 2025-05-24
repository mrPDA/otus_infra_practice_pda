output "admin_sa_name" {
  value = yandex_iam_service_account.admin_sa.name
}

output "instructions" {
  value = <<EOT
✅ Сервисный аккаунт "${yandex_iam_service_account.admin_sa.name}" создан и имеет все необходимые роли.

👉 Чтобы использовать его в Terraform и CLI:

1. Сгенерируй JSON-ключ:

   yc iam key create --service-account-name=${yandex_iam_service_account.admin_sa.name} --output admin-key.json

2. Укажи путь к ключу:

   export YC_SERVICE_ACCOUNT_KEY_FILE=admin-key.json

3. Настрой CLI профиль (опционально):

   yc config profile create terraform-sa
   yc config set service-account-key admin-key.json
   yc config set cloud-id ${var.cloud_id}
   yc config set folder-id ${var.folder_id}

4. Получи IAM токен для Terraform:

   export TF_VAR_yc_token=$(yc iam create-token)

Теперь ты можешь запускать Terraform от имени сервисного аккаунта.
EOT
}