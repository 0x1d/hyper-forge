terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.48.1"
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

module "cloud_base" {
  source = "./hetzner/base"
}

module "cloud_network" {
  source     = "./hetzner/network"
  depends_on = [module.cloud_base]
}

module "cloud_servers" {
  source       = "./hetzner/servers"
  ssh_key      = module.cloud_base.terraform_key
  wireguard_ip = module.cloud_network.wireguard_server_ip
  ingress_ip   = module.cloud_network.ingress_ip
  network      = module.cloud_network.mainnet
  machines     = []
}

module "nodes" {
  source    = "./proxmox"
  image     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  machines  = concat(var.machines.servers, var.machines.clients)
  ssh_key   = file(var.ssh_public_key)
  wireguard = var.wireguard
}
