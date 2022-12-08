resource "hcloud_server" "game" {
  name        = var.server_name
  image       = var.os_image
  server_type = var.server_type
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  firewall_ids = var.game_firewall_ids
  location     = "ash"
  ssh_keys     = var.ssh_keys
}

resource "hcloud_volume" "main" {
  name      = "volume1"
  size      = var.disk_size
  server_id = hcloud_server.game.placement_group_id
  automount = true
  format    = "ext4"
}
