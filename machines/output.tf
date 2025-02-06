output "cloud_network" {
  value = {
    mainnet             = module.cloud_network.mainnet
    subnet              = module.cloud_network.server_subnet
    wireguard_server_ip = module.cloud_network.wireguard_server_ip
    ingress_ip          = module.cloud_network.ingress_ip
  }
}

output "ingress_auth_token" {
  sensitive = true
  value     = module.cloud_servers.frp_auth_token
}
