module "nomad" {
  source      = "./nomad"
  dns_api_key = var.dns_api_key
}
