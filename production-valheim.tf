module "valheim" {
  source            = "./modules/hetzner-game-server"
  server_name       = "valheim"
  server_type       = "cpx31"
  game_firewall_ids = [hcloud_firewall.valheim.id, hcloud_firewall.ssh.id]
  ssh_keys          = [data.hcloud_ssh_key.games.id]
}

data "hcloud_ssh_key" "games" {
  name = "Hetzner"
}

resource "hcloud_firewall" "valheim" {
  name = "valheim-firewall"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "2457"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "2456"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "2456"
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
