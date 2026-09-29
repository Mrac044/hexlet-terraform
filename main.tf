// main.tf - имя файла выбрано произвольно, важно только расширени

// Terraform должен знать ключ, для выполнения команд по API

// Определение переменной, которую нужно будет задать

data "yandex_compute_image" "img_id" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "default" {
  name        = var.server_name
  platform_id = "standard-v1"
  zone        = var.server_zone
  folder_id   = var.yc_folder_id

  resources {
    cores  = var.server_cpu
    memory = var.server_ram
  }

  boot_disk {
    disk_id = yandex_compute_disk.default.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_vpc_network" "default" {
  folder_id = var.yc_folder_id
}

resource "yandex_vpc_subnet" "default" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.5.0.0/24"]
  folder_id      = var.yc_folder_id
}

resource "yandex_compute_disk" "default" {
  name      = "disk-name"
  type      = "network-ssd"
  zone      = var.server_zone
  image_id  = data.yandex_compute_image.img_id.family // идентификатор образа Ubuntu
  folder_id = var.yc_folder_id
  size = "20"
}

resource "yandex_compute_instance" "depender" {
  name        = "depender"
  platform_id = "standart-v1"
  zone        = var.server_zone
  folder_id   = var.yc_folder_id

  resources {
    cores  = var.server_cpu
    memory = var.server_ram
  }

  boot_disk {
    disk_id = yandex_compute_disk.default.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

}

resource "yandex_lb_target_group" "target_group" {
  name      = "target-group"
  region_id = var.server_zone

  target {
    subnet_id = yandex_vpc_subnet.default.id
    address   = yandex_compute_instance.default.network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.default.id
    address   = yandex_compute_instance.depender.network_interface[0].ip_address
  }
}

resource "yandex_lb_network_load_balancer" "lb" {
  name = "load-balancer"
  type = "external"

  listener {
    name        = "lb_listener"
    port        = 80
    target_port = 80
    protocol    = "tcp"
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.target_group.id

    healthcheck {
      name   = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
