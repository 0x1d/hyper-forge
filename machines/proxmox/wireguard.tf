resource "proxmox_virtual_environment_file" "wireguard_cloud_config" {
  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = "pve"

  source_raw {
    data = templatefile("${path.module}/wireguard/cloud-config.yaml", {
      ssh_public_key = var.ssh_key
    })
    file_name = "cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "wireguard_gateway" {
  name            = "wireguard-gateway"
  vm_id           = 150
  node_name       = "pve"
  stop_on_destroy = true

  initialization {
    ip_config {
      ipv4 {
        address = "${var.wireguard.edge_router_ip}/24"
        gateway = var.wireguard.edge_gateway_ip
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.wireguard_cloud_config.id
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 10
  }

  network_device {
    bridge = "vmbr0"
  }
}
