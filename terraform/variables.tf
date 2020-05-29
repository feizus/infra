variable project {
  description = "Project ID"
}

variable region {
  description = "Region"

  # Значение по умолчанию
  default = "europe-west1"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable app_name {
  description = "App name"
}

variable "app_project" {
  type = "string"
  description = "GCP project name"
}

variable zone {
  description = "Time Zone"
}

