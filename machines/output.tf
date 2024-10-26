output "cloud_network" {
  value = {
    mainnet             = module.cloud_network.mainnet
    subnet              = module.cloud_network.server_subnet
    wireguard_server_ip = module.cloud_network.wireguard_server_ip
  }
}
