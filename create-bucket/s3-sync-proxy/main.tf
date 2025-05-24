terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.141.0"
    }
  }
}

data "yandex_vpc_subnet" "subnet" {
  subnet_id = var.subnet_id
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "s3_sync_proxy" {
  name               = "s3-sync-proxy"
  platform_id        = "standard-v3"
  zone               = data.yandex_vpc_subnet.subnet.zone
  service_account_id = var.service_account_id

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.network_interface[0].nat_ip_address
  }

  provisioner "file" {
  source      = "${path.module}/scripts/copy_s3_data.sh"
  destination = "/home/ubuntu/copy_s3_data.sh"
}

provisioner "remote-exec" {
  inline = [
    "set -xe",
    "echo '📦 Installing s3cmd' | tee ~/exec.log",
    "sudo apt-get update",
    "sudo apt-get install -y s3cmd || { echo '❌ Ошибка установки s3cmd'; exit 127; }",

    # задержка и проверка установки
    "sleep 3",
    "which s3cmd >> ~/exec.log || { echo '❌ s3cmd not installed'; exit 127; }",

    # запуск скрипта
    "chmod +x /home/ubuntu/copy_s3_data.sh",
    "ACCESS_KEY='${var.access_key}' SECRET_KEY='${var.secret_key}' TARGET_BUCKET='${var.target_bucket}' bash /home/ubuntu/copy_s3_data.sh >> ~/exec.log 2>&1",
    "touch ~/script_executed.marker",
    "echo '✅ SCRIPT COMPLETED' | tee -a ~/exec.log"
  ]
}

  scheduling_policy {
    preemptible = true
  }

  depends_on = [var.bucket_dependency]
}