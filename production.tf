module "minecraft" {
  source         = "./hetzner-game-server"
  server_type    = "CPX31"
  game_firewalls = [hcloud_firewall.minecraft, hcloud_firewall.ssh]
  ssh_keys       = [hcloud_ssh_key.games.public_key]
}

resource "hcloud_ssh_key" "games" {
  name       = "Game Server SSH Keys"
  public_key = file("~/.ssh/hetzner.pub")
}

resource "hcloud_firewall" "minecraft" {
  name = "minecraft-firewall-tcp"
  rule {
    direction = "in"
    protocol  = "TCP"
    port      = "25565"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "UDP"
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
    protocol  = "TCP"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
