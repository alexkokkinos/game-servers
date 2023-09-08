variable "hcloud_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

terraform {
  cloud {
    organization = "alex-organization"
    workspaces {
      tags = ["game-servers"]
    }
  }
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
    }
  }

  required_version = "~> 1.5.7"
}
