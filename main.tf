// main.tf - имя файла выбрано произвольно, важно только расширение
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.11"
}

// Terraform должен знать ключ, для выполнения команд по API

// Определение переменной, которую нужно будет задать
variable "service_account_key_file" {
  type = string
  sensitive = true
}

provider "yandex" {
  zone  = "ru-central1-a"
  service_account_key_file = var.service_account_key_file
  cloud_id  = "b1gp4gki4si5ftm7sd8g"
  folder_id = var.server_folder_id
}

data "yandex_compute_image" "img_id" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "default" {
  name        = var.server_name
  platform_id = "standard-v1"
  zone        = var.server_zone
  folder_id   = var.server_folder_id

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
  folder_id = var.server_folder_id
}

resource "yandex_vpc_subnet" "default" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.5.0.0/24"]
  folder_id      = var.server_folder_id
}

resource "yandex_compute_disk" "default" {
  name      = "disk-name"
  type      = "network-ssd"
  zone      = "ru-central1-a"
  image_id  = data.yandex_compute_image.img_id.family // идентификатор образа Ubuntu
  folder_id = var.server_folder_id
  size = "20"
}

