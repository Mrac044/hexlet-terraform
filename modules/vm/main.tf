data "yandex_client_config" "client" {}

locals {
  folder_id = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
}

resource "yandex_compute_instance" "vm" {
  name = var.server_name
  zone = var.server_zone

  resources {
    cores  = var.server_cpu
    memory = var.server_ram
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.img.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = var.nat_enable
  }

  metadata = {
    user-data = <<-EOF
    #!/bin/bash
    echo 'export DB_HOST="${module.yandex-postgresql.cluster_fqdns_list[0][0]}"' >> /etc/environment
    EOF
    ssh-keys  = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.network_interface[0].nat_ip_address
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

  provisioner "remote-exec" {
    inline = [
      <<EOT
sudo docker run -d -p 0.0.0.0:80:3000 \
  -e DB_TYPE=postgres \
  -e DB_NAME=${module.yandex-postgresql.databases[0]} \
  -e DB_HOST=${module.yandex-postgresql.cluster_fqdns_list[0][0]} \
  -e DB_PORT=6432 \
  -e DB_USER=${module.yandex-postgresql.owners_data[0].user} \
  -e DB_PASS=${module.yandex-postgresql.owners_data[0].password} \
  ghcr.io/requarks/wiki:2
EOT
    ]
  }
}