terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/hyper-forge/platform"
  }
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.3.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.3.0"
    }
  }
}
provider "nomad" {}

provider "vault" {
  skip_tls_verify  = true
  skip_child_token = true
}


module "nomad" {
  source = "./nomad"
}

module "vault" {
  source = "./vault"
}
