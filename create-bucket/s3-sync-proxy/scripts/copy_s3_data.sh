#!/bin/bash
set -e
set -x

LOG_FILE="/home/ubuntu/s3copy.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
  echo "[LOG] $1"
}

log "🔐 Проверка переменных окружения"
if [[ -z "$ACCESS_KEY" || -z "$SECRET_KEY" || -z "$TARGET_BUCKET" ]]; then
  echo "❌ Переменные окружения ACCESS_KEY, SECRET_KEY или TARGET_BUCKET не заданы"
  exit 78
fi

log "📦 Установка s3cmd"
sudo apt-get update && sudo apt-get install -y s3cmd

log "⚙️ Создание ~/.s3cfg"
cat <<EOF > /home/ubuntu/.s3cfg
[default]
access_key = ${ACCESS_KEY}
secret_key = ${SECRET_KEY}
host_base = storage.yandexcloud.net
host_bucket = %(bucket)s.storage.yandexcloud.net
use_https = True
EOF

chown ubuntu:ubuntu /home/ubuntu/.s3cfg
chmod 600 /home/ubuntu/.s3cfg

log "📂 Копирование из otus-mlops-source-data в $TARGET_BUCKET"
s3cmd --config=/home/ubuntu/.s3cfg cp --recursive --acl-public \
  s3://otus-mlops-source-data/ \
  s3://$TARGET_BUCKET/

log "📄 Содержимое целевого бакета:"
s3cmd --config=/home/ubuntu/.s3cfg ls s3://$TARGET_BUCKET/

log "✅ Копирование завершено. ВМ завершится через 10 минут."
sudo shutdown -h +10 "Автоматическое завершение после копирования"