#!/bin/bash

SA_NAME="terraform-admin-sa"
KEY_FILE="admin-key.json"

echo "📦 Генерация JSON-ключа для сервисного аккаунта '$SA_NAME'..."

yc iam key create \
  --service-account-name="$SA_NAME" \
  --output="$KEY_FILE"

echo "✅ Ключ сохранён в: $KEY_FILE"
echo "👉 Не забудь: export YC_SERVICE_ACCOUNT_KEY_FILE=$KEY_FILE"