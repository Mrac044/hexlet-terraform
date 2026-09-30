variable "name" {
  description = "Instance name"
  type        = string
}

variable "server_zone" {
  description = "Instance Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "server_cpu" {
  description = "Instance CPU cores"
  type        = number
  default     = 2
}

variable "server_ram" {
  description = "Instance RAM in GB"
  type        = number
  default     = 4
}

variable "nat" {
  description = "Enable public NAT"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "image_id" {
  description = "Boot disk image ID"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_host" {
  description = "PostgreSQL host"
  type        = string
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 6432
}

variable "db_user" {
  description = "PostgreSQL username"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}