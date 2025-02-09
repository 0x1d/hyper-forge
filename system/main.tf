terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/hyper-forge/system"
  }
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.21.0"
    }
  }
}
