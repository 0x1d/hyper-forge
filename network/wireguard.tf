module "wireguard" {
  source = "./wireguard"
  cloud = {
    network = var.cloud_subnet_range
  }
  edge = {
    network = var.wireguard.edge_network
  }
  clients = var.wireguard.clients
  wireguard = {
    network          = "${var.wireguard.network}"
    server_ip        = "${var.wireguard.server_ip}/32"
    router_ip        = "${var.wireguard.router_ip}/32"
    server_public_ip = var.wireguard_server_ip
  }
}

resource "local_file" "wg_server_config" {
  content  = module.wireguard.wg_server_config
  filename = "${path.module}/target/wireguard/server/etc/wireguard/wg0.conf"
}

resource "local_file" "wg_router_config" {
  content  = module.wireguard.wg_router_config
  filename = "${path.module}/target/wireguard/router/etc/wireguard/wg0.conf"
}

resource "local_file" "wg_client_config" {
  for_each = module.wireguard.wg_client_config
  content  = each.value.rendered
  filename = "${path.module}/target/wireguard/clients/${each.key}.conf"
}
