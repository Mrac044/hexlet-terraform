// main.tf - имя файла выбрано произвольно, важно только расширени

// Terraform должен знать ключ, для выполнения команд по API

// Определение переменной, которую нужно будет задать

resource "yandex_vpc_network" "net" {
  name = "tfhexlet"
}

resource "yandex_vpc_subnet" "subnet" {
  name = "tfhexlet"
  zone = var.server_zone
  network_id = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.192.0/24"]
}

resource "yandex_mdb_postgresql_cluster" "dbcluster" {
  name        = "tfhexlet"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.net.id

  config {
    version = var.yc_postgresql_version
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 15
    }
    postgresql_config = {
      max_connections = 100
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnet.id
  }
}

resource "yandex_mdb_postgresql_user" "dbuser" {
  cluster_id = yandex_mdb_postgresql_cluster.dbcluster.id
  name       = var.db_user
  password   = var.db_password
}

resource "yandex_mdb_postgresql_database" "db" {
  cluster_id = yandex_mdb_postgresql_cluster.dbcluster.id
  name       = var.db_name
  owner      = yandex_mdb_postgresql_user.dbuser.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
}

data "yandex_compute_image" "img" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "vm" {
  name = "tfhexlet"
  zone = var.server_zone

  resources {
    cores = var.server_cpu
    memory = var.server_ram
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.img.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host = self.network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
  inline = [
<<EOT
sudo docker run -d -p 0.0.0.0:80:3000 \
  -e DB_TYPE=postgres \
  -e DB_NAME=${var.db_name} \
  -e DB_HOST=${yandex_mdb_postgresql_cluster.dbcluster.host[0].fqdn} \
  -e DB_PORT=6432 \
  -e DB_USER=${var.db_user} \
  -e DB_PASS=${var.db_password} \
  ghcr.io/requarks/wiki:2
EOT
    ]
  }
}

# data "yandex_compute_image" "img_id" {
#   family = "ubuntu-2204-lts"
# }

# resource "yandex_compute_instance" "default" {
#   name        = var.server_name
#   platform_id = "standard-v1"
#   zone        = var.server_zone
#   folder_id   = var.yc_folder_id

#   resources {
#     cores  = var.server_cpu
#     memory = var.server_ram
#   }

#   boot_disk {
#     disk_id = yandex_compute_disk.default.id
#   }

#   network_interface {
#     subnet_id = yandex_vpc_subnet.default.id
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
#   }
# }

# resource "yandex_vpc_network" "default" {
#   folder_id = var.yc_folder_id
# }

# resource "yandex_vpc_subnet" "default" {
#   zone           = "ru-central1-a"
#   network_id     = yandex_vpc_network.default.id
#   v4_cidr_blocks = ["10.5.0.0/24"]
#   folder_id      = var.yc_folder_id
# }

# resource "yandex_compute_disk" "default" {
#   name      = "disk-name"
#   type      = "network-ssd"
#   zone      = var.server_zone
#   image_id  = data.yandex_compute_image.img_id.family // идентификатор образа Ubuntu
#   folder_id = var.yc_folder_id
#   size = "20"
# }

# resource "yandex_compute_instance" "depender" {
#   name        = "depender"
#   platform_id = "standart-v1"
#   zone        = var.server_zone
#   folder_id   = var.yc_folder_id

#   resources {
#     cores  = var.server_cpu
#     memory = var.server_ram
#   }

#   boot_disk {
#     disk_id = yandex_compute_disk.default.id
#   }

#   network_interface {
#     subnet_id = yandex_vpc_subnet.default.id
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
#   }

# }

# resource "yandex_lb_target_group" "target_group" {
#   name      = "target-group"
#   region_id = var.server_zone

#   target {
#     subnet_id = yandex_vpc_subnet.default.id
#     address   = yandex_compute_instance.default.network_interface[0].ip_address
#   }

#   target {
#     subnet_id = yandex_vpc_subnet.default.id
#     address   = yandex_compute_instance.depender.network_interface[0].ip_address
#   }
# }

# resource "yandex_lb_network_load_balancer" "lb" {
#   name = "load-balancer"
#   type = "external"

#   listener {
#     name        = "lb_listener"
#     port        = 80
#     target_port = 80
#     protocol    = "tcp"
#   }

#   attached_target_group {
#     target_group_id = yandex_lb_target_group.target_group.id

#     healthcheck {
#       name   = "http"
#       http_options {
#         port = 80
#         path = "/"
#       }
#     }
#   }
# }
