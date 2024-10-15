terraform {
  #backend "consul" {
  #  scheme = "http"
  #  path   = "terraform/hyper-forge"
  #}
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }
}

provider "proxmox" {
  insecure = true
  tmp_dir  = "/var/tmp"

  ssh {
    agent = true
  }
}

module "nodes" {
  source   = "./proxmox"
  image    = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  machines = concat(var.machines.servers, var.machines.clients)
  ssh_keys = [trimspace(file(var.ssh_public_key))]
}

