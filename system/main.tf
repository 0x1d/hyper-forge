resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.tpl", {
    servers = join("\n", tolist([for k, v in var.machines.servers : v.ip]))
    clients = join("\n", tolist([for k, v in var.machines.clients : v.ip]))
  })
  filename = "${path.module}/target/inventory.cfg"
}

resource "local_file" "consul_server_config" {
  content = templatefile("${path.module}/config/server/etc/consul.d/consul.hcl.tpl", {
    servers = jsonencode(tolist([for k, v in var.machines.servers : "${v.ip}"]))
  })
  filename = "${path.module}/target/server/etc/consul.d/consul.hcl"
}
resource "local_file" "consul_client_config" {
  content = templatefile("${path.module}/config/client/etc/consul.d/consul.hcl.tpl", {
    servers = jsonencode(tolist([for k, v in var.machines.servers : "${v.ip}"]))
  })
  filename = "${path.module}/target/client/etc/consul.d/consul.hcl"
}
