terraform {
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
  source = "./terraform/modules/proxmox"
  image = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  machines = concat(local.servers, local.clients)
  ssh_keys = [trimspace(file(var.ssh_public_key))]
}

