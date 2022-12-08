module "minecraft" {
  source         = "./modules/hetzner-game-server"
  server_type    = "CPX31"
  game_firewalls = [hcloud_firewall.minecraft, hcloud_firewall.ssh]
  ssh_keys       = [data.hcloud_ssh_key.games.public_key]
}

data "hcloud_ssh_key" "games" {
  name = "Hetzner"
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

resource "hcloud_firewall" "ssh" {
  name = "game-server-ssh"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
