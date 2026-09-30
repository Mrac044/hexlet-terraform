# Вывод внутреннего IP-адреса
output "vm_internal_ip" {
  value       = yandex_compute_instance.vm.network_interface.0.ip_address
  description = "Внутренний IP-адрес виртуальной машины"
}

# Вывод внешнего IP-адреса
output "vm_external_ip" {
  value       = yandex_compute_instance.vm.network_interface.0.nat_ip_address
  description = "Внешний IP-адрес виртуальной машины (NAT)"
}