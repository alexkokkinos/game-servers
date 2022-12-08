variable "os_image" {
  type    = string
  default = "debian-11"
}

variable "disk_size" {
  default = 20
}

variable "game_firewall_ids" {
  type = list(number)
}

variable "ssh_keys" {
  type = list(string)
}

variable "server_type" {
  type = string
}

variable "server_name" {
  type = string
}
