resource "random_password" "frp_auth_token" {
  length  = 16
  special = true
}

module "frps" {
  source          = "./frp"
  ip              = var.ingress_ip.ip_address
  frps_auth_token = random_password.frp_auth_token.result
  frps_port       = "7000"
  #frps_subdomain_host = "proxy.dcentral.systems"
  proxy_ports = ["2222", "7000", "443", "80"]
}

resource "hcloud_server" "reverse_proxy" {
  name        = "frps"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "fsn1"
  ssh_keys    = [var.ssh_key.id]
  user_data   = module.frps.cloud_config

  network {
    network_id = var.network.id
  }
  public_net {
    ipv4 = var.ingress_ip.id
  }
}

output "frpc_ini" {
  sensitive = true
  value     = module.frps.client_config
}
