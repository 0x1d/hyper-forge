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
