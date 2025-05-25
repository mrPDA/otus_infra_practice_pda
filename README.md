# Инфраструктура для Spark кластера в Yandex Cloud

Этот проект содержит конфигурацию Terraform для развертывания Spark кластера в Yandex Cloud Data Proc с настроенной сетевой инфраструктурой и безопасным доступом к данным.

## 📋 Структура проекта

```
.
├── create_spark/        # Основная конфигурация Spark кластера
├── create-bucket/       # Настройка S3 бакета для данных
└── create-admin-sa/     # Создание сервисного аккаунта (приватный)
```

## 🚀 Начало работы

1. Склонируйте репозиторий:
```bash
git clone <repository-url>
cd otus-practice-cloud-infra
```



2. Создайте файл `.env`

3. Настройте переменные окружения в файле `.env`:
   - Укажите пути к SSH ключам
   - Добавьте идентификаторы облака и папки
   - Настройте доступы к S3

4. Создайте сервисный аккаунт и получите ключи доступа:


5. Создайте и настройте кластер:
```bash
cd create_spark
source .env
terraform init
terraform apply
```

## 🔋 Возможности

- ✅ Автоматическое создание Spark кластера
- ✅ Настройка NAT для доступа в интернет
- ✅ Безопасные группы доступа
- ✅ Интеграция с Object Storage
- ✅ Масштабируемая архитектура

## 🛠 Конфигурация кластера

- Мастер-узел: s3-c2-m8, 40 ГБ SSD
- Дата-узлы: 3× s3-c4-m16, 128 ГБ SSD
- Сеть: Выделенная подсеть с NAT
- Безопасность: Настроенные группы безопасности

## 📊 Примеры использования

Подключение к мастер-узлу:
```bash
ssh ubuntu@<master-node-ip>
```

Копирование данных из S3:
```bash
hadoop distcp \
  -D fs.s3a.access.key=YOUR_ACCESS_KEY \
  -D fs.s3a.secret.key=YOUR_SECRET_KEY \
  -D fs.s3a.endpoint=storage.yandexcloud.net \
  s3a://your-bucket/* \
  hdfs:///user/ubuntu/data/
```

```bash
ssh -o StrictHostKeyChecking=no ubuntu@rc1a-dataproc-m-****_fv.mdb.yandexcloud.net "hadoop distcp \
  -D fs.s3a.access.key=$TF_VAR_s3_access_key \
  -D fs.s3a.secret.key=$TF_VAR_s3_secret_key \
  -D fs.s3a.endpoint=storage.yandexcloud.net \
  -D dfs.replication=1 \
  -D dfs.blocksize=128m \
  -D mapreduce.job.maps=10 \
  -D mapreduce.map.memory.mb=2048 \
  -D mapreduce.map.java.opts=-Xmx1536m \
  -D dfs.client.use.datanode.hostname=true \
  -update -log /tmp/distcp_log \
  s3a://$TF_VAR_bucket_name/* \
  hdfs:///user/ubuntu/data/"
```

Результат копирования
![copy_rez](https://github.com/user-attachments/assets/4bf55f96-71f7-4fb9-ada8-4240830eaac7)

## 🧹 Очистка ресурсов

Для удаления всех созданных ресурсов:
```bash
cd create_spark
terraform destroy
```

## 🔒 Безопасность

- Все секреты хранятся в `.env` (не коммитится в git)
- Используются сервисные аккаунты с минимальными правами
- Настроены группы безопасности для ограничения доступа

## 📝 Лицензия

MIT
