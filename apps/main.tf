terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/hyper-forge/apps"
  }
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.3.1"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.21.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.3.0"
    }
  }
}

provider "nomad" {}
provider "consul" {}
provider "vault" {
  skip_tls_verify  = true
  skip_child_token = true
}

locals {
  nfs = {
    host        = "192.168.1.3"
    port        = 2222
    private_key = file("~/.ssh/id_ed25519")
    user        = "master"
  }
}
