# Инфраструктура для Spark кластера в Yandex Cloud

Этот проект содержит конфигурацию Terraform для развертывания Spark кластера в Yandex Cloud Data Proc с настроенной сетевой инфраструктурой и безопасным доступом к данным.

Адрес бакета с данными s3a://otus-copy-b1gjj3po03aa3m4j8ps5/

## 📋 Структура проекта

```
.
├── create_spark/        # Основная конфигурация Spark кластера
│   ├── main.tf         # Основная конфигурация ресурсов
│   ├── variables.tf    # Определение переменных
│   └── outputs.tf      # Выходные значения
├── create-bucket/      # Настройка S3 бакета для данных
│   ├── main.tf         # Конфигурация S3 bucket
│   └── s3-sync-proxy/  # Настройка прокси для синхронизации
└── create-admin-sa/    # Создание сервисного аккаунта
    └── create-key.sh   # Скрипт создания ключей
```

## 🚀 Начало работы

### Предварительные требования

- Установленный Terraform
- Аккаунт в Yandex Cloud
- Настроенный CLI Yandex Cloud
- SSH ключи для доступа к кластеру

### Настройка окружения

1. Склонируйте репозиторий:
```bash
git clone https://github.com/yourusername/otus-practice-cloud-infra.git
cd otus-practice-cloud-infra
```

2. Создайте сервисный аккаунт и получите ключи:

3. Создайте файл `.env` н

4. Настройте переменные окружения в файле :
   - YC_TOKEN - токен для доступа к Yandex Cloud
   - YC_CLOUD_ID - ID облака
   - YC_FOLDER_ID - ID папки
   - TF_VAR_s3_access_key - ключ доступа к S3
   - TF_VAR_s3_secret_key - секретный ключ S3

### Развертывание инфраструктуры

1. Создайте S3 бакет для данных:
```bash
cd create-bucket
terraform init
terraform apply
cd ..
```

2. Создайте и настройте кластер:
```bash
cd create_spark
terraform init
terraform apply
```

## 🛠 Конфигурация кластера

### Характеристики узлов
- Мастер-узел: s3-c2-m8 (2 vCPU, 8 GB RAM, 40 GB SSD)
- Рабочие узлы: 3× s3-c4-m16 (4 vCPU, 16 GB RAM, 128 GB SSD)

### Сетевая конфигурация
- Выделенная VPC сеть
- NAT-шлюз для доступа в интернет
- Настроенные группы безопасности

### Программное обеспечение
- Apache Spark
- Apache Hadoop
- Jupyter Notebook
- Python 3

## 📊 Примеры использования

### Подключение к кластеру
```bash
ssh -o StrictHostKeyChecking=no ubuntu@<master-node-ip>
```

### Копирование данных из S3 в HDFS
```bash
hadoop distcp \
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
  hdfs:///user/ubuntu/data/
```

### Результат копирования данных в HDFS

После выполнения команды копирования, мы можем увидеть успешно скопированные файлы в HDFS:

```bash
hdfs dfs -ls /user/ubuntu/data/
```

Результат показывает, что данные успешно скопированы в HDFS:
- Всего скопировано 40 файлов
- Данные за период с августа 2019 по ноябрь 2022
- Все файлы имеют корректные права доступа и принадлежат пользователю ubuntu
- Размер блоков и репликация соответствуют заданным параметрам

![Результат копирования данных]

![copy_rez](https://github.com/user-attachments/assets/67c22d58-2d3c-4900-8a25-44738c86dd91)


## 🧹 Очистка ресурсов

Для удаления всех созданных ресурсов выполните:

1. Удаление кластера:
```bash
cd create_spark
terraform destroy
```

2. Удаление S3 бакета:
```bash
cd ../create-bucket
terraform destroy
```

## 🔒 Безопасность

### Хранение секретов
- Все чувствительные данные не коммитится в git
- Ключи сервисного аккаунта хранятся локально
- Используется принцип минимальных привилегий

### Сетевая безопасность
- Кластер размещен в приватной подсети
- Доступ только через SSH
- Настроены security groups

## 📝 Лицензия

[MIT](LICENSE)
