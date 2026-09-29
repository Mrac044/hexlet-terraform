# Secret key path

variable "service_account_key_file" {
  description = "Auth key file path"
  type = string
  default = "authorized_key.json"
  sensitive = true
}

# Resource vars

variable "server_name" {
  description = "Instance name"
  type        = string
}

variable "server_zone" {
  description = "Instance yandex cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "server_cpu" {
  description = "Instance CPU cores"
  type        = number
  default     = "2"
}

variable "server_ram" {
  description = "Instance RAM memory resource"
  type        = number
  default     = "4"
}

variable "yc_folder_id" {
  description = "Working folder id"
  type        = string
}

variable "yc_cloud_id" {
  description = "Working cloud id"
  type        = string
}

# Database vars

variable "db_name" {
  description = "Managed database name"
  type = string
}

variable "db_user" {
  description = "Managed database username"
  type = string
}

variable "db_password" {
  description = "Managed database password"
  type = string
}

variable "yc_postgresql_version" {
  description = "Managed database postgresql version"
  type = number
  default = 18
}