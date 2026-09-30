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

module "yandex-postgresql" {
  source = "github.com/terraform-yc-modules/terraform-yc-postgresql?ref=1.0.2"
  network_id  = yandex_vpc_network.net.id
  name        = "tfhexlet"
  description = "Single-node PostgreSQL cluster for test purposes"

  hosts_definition = [
    {
      zone             = var.server_zone
      assign_public_ip = false
      subnet_id        = yandex_vpc_subnet.subnet.id
    }
  ]

  postgresql_config = {
    max_connections = 100
  }

  databases = [
    {
      name       = "hexlet"
      owner      = var.db_user
      lc_collate = "ru_RU.UTF-8"
      lc_type    = "ru_RU.UTF-8"
      extensions = ["uuid-ossp", "xml2"]
    },
    {
      name       = "hexlet-test"
      owner      = var.db_user
      lc_collate = "ru_RU.UTF-8"
      lc_type    = "ru_RU.UTF-8"
      extensions = ["uuid-ossp", "xml2"]
    }
  ]

  owners = [
    {
      name       = var.db_user
      conn_limit = 15
    }
  ]

  users = [
    {
      name        = "guest"
      conn_limit  = 30
      permissions = ["hexlet"]
      settings = {
        pool_mode                   = "transaction"
        prepared_statements_pooling = true
      }
    }
  ]
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

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

module "vm" {
  source = "./modules/vm"

  name        = "tfhexlet"
  server_zone = "ru-central1-a"
  server_cpu  = 2
  server_ram  = 4
  nat         = true

  subnet_id = yandex_vpc_subnet.subnet.id
  image_id  = data.yandex_compute_image.ubuntu.id

  db_name     = module.yandex-postgresql.databases[0]
  db_host     = module.yandex-postgresql.cluster_fqdns_list[0][0]
  db_port     = 6432
  db_user     = module.yandex-postgresql.owners_data[0].user
  db_password = module.yandex-postgresql.owners_data[0].password
}

output "server_internal_ip" {
  value = module.vm.vm_internal_ip
}

output "server_external_ip" {
  value = module.vm.vm_external_ip
}