output "wg_server_config" {
  value = data.template_file.wg_server_config.rendered
}

output "wg_router_config" {
  value = data.template_file.wg_edge_router_config.rendered
}

output "wg_client_config" {
  value = data.template_file.wg_client_config
}
