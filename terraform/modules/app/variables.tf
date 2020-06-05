variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable zone {
  description = "Time Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app"
}
