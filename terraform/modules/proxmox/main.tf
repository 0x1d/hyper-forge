terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }
}

variable "image" {
  type = string
  default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "ssh_keys" {
  type = list(string)
  default = []
}

variable "machines" {
  type = list(object({
    id = number
    name = string
    ip = string
    gateway = string
    disk_size = number
    cores = number
    memory = number
  }))
  default = []
}

resource "proxmox_virtual_environment_vm" "node" {
  for_each  = { for machine in var.machines : machine.name => machine}
  vm_id     = each.value.id
  name      = each.value.name
  node_name = "pve"

  initialization {

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = each.value.gateway
      }
    }

    user_account {
      username = "root"
      keys     = var.ssh_keys
    }
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = each.value.disk_size
  }

  network_device {
    bridge = "vmbr0"
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }
  stop_on_destroy = true
  lifecycle {
    ignore_changes = [ cpu[0].architecture ]
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url = var.image
}

