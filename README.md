# Yandex Cloud Infrastructure Practice

This repository contains Terraform configurations and scripts for managing infrastructure in Yandex Cloud.

## Components

- **create-admin-sa**: Service account creation and management
- **create-bucket**: S3 bucket creation and management with Python utilities
- **create_spark**: Spark cluster infrastructure setup

## Prerequisites

- Terraform >= 1.5.7
- Yandex Cloud CLI
- Python 3.x (for bucket management scripts)
- Access to Yandex Cloud with appropriate permissions

## Setup

1. Configure Yandex Cloud CLI
2. Create service account with appropriate permissions
3. Set up environment variables:
   - Copy `.env.example` to `.env` in the create-bucket directory
   - Fill in your Yandex Cloud credentials:
     ```
     YC_ACCESS_KEY_ID=your_access_key_here
     YC_SECRET_ACCESS_KEY=your_secret_key_here
     ```
4. Initialize Terraform in each component directory
5. Apply Terraform configurations as needed

## Usage

Each directory contains its own Terraform configuration and can be applied independently:

```bash
cd <component-directory>
terraform init
terraform apply
```

### Bucket Management

To check bucket size and contents:

```bash
cd create-bucket
source .env
python check_bucket_size.py
```

### Spark Cluster

Spark cluster commands are available in the `create_spark/command.txt` file. Make sure to set up environment variables before running the commands:

```bash
export YC_ACCESS_KEY_ID=your_access_key_here
export YC_SECRET_ACCESS_KEY=your_secret_key_here
```

## Security Note

- Sensitive data and credentials are excluded from git tracking
- Use environment variables for credentials
- Never commit `.env` files or any files containing secrets
- Keep your service account keys secure