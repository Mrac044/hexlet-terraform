variable "service_account_key_file" {
  description = "Auth key file path"
  type = string
  default = "authorized_key.json"
  sensitive = true
}

variable "server_name" {
  description = "Instance name"
  type        = string
  default     = "test"
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
  description = "Instance RAM resource"
  type        = number
  default     = "4"
}

variable "yc_folder_id" {
  description = "Working folder id"
  type        = string
  default     = "b1g9mu82ledrgsplj3oi"
}

variable "yc_cloud_id" {
  description = "Working cloud id"
  type        = string
  default     = "b1gp4gki4si5ftm7sd8g"
}