data "yandex_compute_image" "img" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  name = var.name
  zone = var.server_zone

  resources {
    cores  = var.server_cpu
    memory = var.server_ram
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
  }

  metadata = {
    user-data = <<-EOF
      #!/bin/bash
      echo 'export DB_HOST="${var.db_host}"' >> /etc/environment
    EOF

    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sudo docker run -d -p 0.0.0.0:80:3000 \
          -e DB_TYPE=postgres \
          -e DB_NAME=${var.db_name} \
          -e DB_HOST=${var.db_host} \
          -e DB_PORT=${var.db_port} \
          -e DB_USER=${var.db_user} \
          -e DB_PASS=${var.db_password} \
          ghcr.io/requarks/wiki:2
      EOT
    ]
  }
}