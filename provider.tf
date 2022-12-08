variable "hcloud_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

terraform {
  required_providers {
    hcloud = {
      version = ">= 1.36.1"
      source  = "hetznercloud/hcloud"
    }
  }

  required_version = "~> 1.3.6"
}
