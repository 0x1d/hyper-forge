terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/hyper-forge/network"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.3.0"
    }
  }
}
