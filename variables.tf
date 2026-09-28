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

variable "server_folder_id" {
  description = "Working folder id"
  type        = string
  default     = "b1g9mu82ledrgsplj3oi"
}