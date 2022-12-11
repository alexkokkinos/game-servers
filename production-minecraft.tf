module "minecraft" {
  source            = "./modules/hetzner-game-server"
  server_name       = "minecraft"
  server_type       = "cpx31"
  game_firewall_ids = [hcloud_firewall.minecraft.id, hcloud_firewall.ssh.id]
  ssh_keys          = [data.hcloud_ssh_key.games.id]
}

resource "hcloud_firewall" "minecraft" {
  name = "minecraft-firewall-tcp"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "25565"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "25565"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
