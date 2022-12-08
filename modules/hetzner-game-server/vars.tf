variable "os_image" {
  type    = string
  default = "debian-11"
}

variable "disk_size" {
  default = 20
}

variable "game_firewalls" {
  type = list(object({
    rule = map()
  }))
}

variable "ssh_keys" {
  type = list(any)
}
