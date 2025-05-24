output "vm_public_ip" {
  description = "Публичный IP-адрес временной ВМ"
  value       = yandex_compute_instance.s3_sync_proxy.network_interface[0].nat_ip_address
}