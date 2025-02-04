output "wireguard_server_ip" {
  value = hcloud_primary_ip.wireguard
}
output "ingress_ip" {
  value = hcloud_primary_ip.ingress
}
output "mainnet" {
  value = hcloud_network.network
}
output "server_subnet" {
  value = hcloud_network_subnet.servers
}
