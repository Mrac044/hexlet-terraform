variable "name" {
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

variable "nat" {
    description = "Is NAT enable"
    type        = bool
    default     = false
}