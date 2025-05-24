import boto3
import sys
import os
from botocore.config import Config

# Initialize S3 client
s3_client = boto3.client(
    service_name='s3',
    endpoint_url='https://storage.yandexcloud.net',
    aws_access_key_id=os.environ.get('YC_ACCESS_KEY_ID'),
    aws_secret_access_key=os.environ.get('YC_SECRET_ACCESS_KEY'),
    region_name='ru-central1'
)

def get_bucket_size(bucket_name):
    total_size = 0
    total_objects = 0
    
    try:
        paginator = s3_client.get_paginator('list_objects_v2')
        for page in paginator.paginate(Bucket=bucket_name):
            if 'Contents' in page:
                for obj in page['Contents']:
                    total_size += obj['Size']
                    total_objects += 1
        
        # Convert to human readable format
        size_mb = total_size / (1024 * 1024)  # Convert to MB
        if size_mb >= 1024:
            size_gb = size_mb / 1024
            size_str = f"{size_gb:.2f} GB"
        else:
            size_str = f"{size_mb:.2f} MB"
            
        print(f"Bucket: {bucket_name}")
        print(f"Total objects: {total_objects}")
        print(f"Total size: {size_str}")
        
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    bucket_name = "otus-copy-b1gjj3po03aa3m4j8ps5"
    get_bucket_size(bucket_name)
