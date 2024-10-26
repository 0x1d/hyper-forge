resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.tpl", {
    wireguard_server = var.wireguard_server_ip
    wireguard_router = var.wireguard.edge_router_ip
  })
  filename = "${path.module}/target/inventory.cfg"
}

