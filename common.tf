data "hcloud_ssh_key" "games" {
  name = "Hetzner"
}

resource "hcloud_firewall" "ssh" {
  name = "game-server-ssh"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      var.home_ip
    ]
  }
}
