terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.3.1"
    }
  }
}

provider "nomad" {}

locals {
  nfs = {
    host        = "192.168.1.3"
    port        = 2222
    private_key = file("~/.ssh/id_ed25519")
    user        = "master"
  }
}
