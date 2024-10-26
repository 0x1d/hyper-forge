terraform {
  required_providers {
    wireguard = {
      source  = "OJFord/wireguard"
      version = "0.3.1"
    }
  }
}

resource "wireguard_asymmetric_key" "wg_router_key" {}
resource "wireguard_asymmetric_key" "wg_server_key" {}

resource "wireguard_asymmetric_key" "wg_client_key" {
  for_each = { for client in var.clients : client.name => client }
}

data "template_file" "wg_server_config" {
  template = file("${path.module}/config/server.conf")
  vars = {
    server_private_key  = wireguard_asymmetric_key.wg_server_key.private_key
    router_public_key   = wireguard_asymmetric_key.wg_router_key.public_key
    edge_network        = var.edge.network
    cloud_network       = var.cloud.network
    wireguard_server_ip = var.wireguard.server_ip
    wireguard_network   = var.wireguard.network
    peers               = <<-EOT
      %{for k, v in { for client in var.clients : client.name => client } }
      # ${k}
      [Peer]
      PublicKey = ${wireguard_asymmetric_key.wg_client_key[k].public_key}
      AllowedIPs = ${v.client_ip}
      %{endfor}
    EOT
  }
}

data "template_file" "wg_edge_router_config" {
  template = file("${path.module}/config/router.conf")
  vars = {
    server_public_key   = wireguard_asymmetric_key.wg_server_key.public_key
    router_private_key  = wireguard_asymmetric_key.wg_router_key.private_key
    server_public_ip    = var.wireguard.server_public_ip
    wireguard_network   = var.wireguard.network
    wireguard_router_ip = var.wireguard.router_ip
  }
}


data "template_file" "wg_client_config" {
  for_each = { for client in var.clients : client.name => client }
  template = file("${path.module}/config/client.conf")
  vars = {
    server_public_key   = wireguard_asymmetric_key.wg_server_key.public_key
    server_public_ip    = var.wireguard.server_public_ip
    edge_network        = var.edge.network
    wireguard_client_ip = each.value.client_ip
    client_private_key  = wireguard_asymmetric_key.wg_client_key[each.key].private_key
    client_public_key   = wireguard_asymmetric_key.wg_client_key[each.key].public_key
  }
}

