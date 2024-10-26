terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "node" {
  for_each  = { for machine in var.machines : machine.name => machine }
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
      keys     = [trimspace(var.ssh_key)]
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
    floating  = each.value.memory
  }
  stop_on_destroy = true
  lifecycle {
    ignore_changes = [cpu[0].architecture]
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url          = var.image
}

