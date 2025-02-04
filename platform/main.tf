module "nomad" {
  source      = "./nomad"
  dns_api_key = var.dns_api_key
  ingress_config = {
    custom_domains = var.domains
    ip             = var.ingress_ip
    auth_token     = var.ingress_auth_token
  }
}
