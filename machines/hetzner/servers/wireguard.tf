resource "hcloud_server" "wireguard" {
  name        = "regia-occulta"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "fsn1"
  ssh_keys    = [var.ssh_key.id]
  user_data   = templatefile("${path.module}/wireguard/cloud-config.yaml", {})

  network {
    network_id = var.network.id
    alias_ips  = []
  }
  public_net {
    ipv4 = var.wireguard_ip.id
  }
}
