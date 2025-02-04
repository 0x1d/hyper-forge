# ---------------------------------------------------------------------
# Networks
# ---------------------------------------------------------------------
resource "hcloud_network" "network" {
  name     = "mainnet"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "servers" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}


# ---------------------------------------------------------------------
# Reserved IP Addresses
# ---------------------------------------------------------------------
resource "hcloud_primary_ip" "ingress" {
  name          = "ingress"
  type          = "ipv4"
  assignee_type = "server"
  datacenter    = "fsn1-dc14"
  auto_delete   = false
  labels = {
    "role" : "reverse-proxy"
  }
}
resource "hcloud_primary_ip" "wireguard" {
  name          = "wireguard"
  type          = "ipv4"
  assignee_type = "server"
  datacenter    = "fsn1-dc14"
  auto_delete   = false
  labels = {
    "role" : "wireguard"
  }
}
