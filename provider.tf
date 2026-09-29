terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.11"
}

provider "yandex" {
  zone  = var.server_zone
  service_account_key_file = var.service_account_key_file
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
}