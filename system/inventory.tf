resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.tpl", {
    servers = join("\n", tolist([for k, v in var.machines.servers : v.ip]))
    clients = join("\n", tolist([for k, v in var.machines.clients : v.ip]))
  })
  filename = "${path.module}/target/inventory.cfg"
}

