variable "dns_api_key" {
  description = "API key for DNS provider"
}
variable "domains" {

}
variable "ingress_ip" {

}
variable "ingress_auth_token" {

}

module "traefik_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "traefik"
    path         = "/volume1/nomad/traefik"
    capacity_min = "1GiB"
    capacity_max = "1GiB"
  }
}


resource "nomad_job" "ingress" {
  jobspec = file("${path.module}/jobs/ingress.hcl")
  hcl2 {
    vars = {
      dns_api_key       = var.dns_api_key
      traefik_volume_id = "traefik"
      traefik_toml      = file("${path.module}/jobs/config/ingress/traefik.toml")
      frpc_ini = templatefile("${path.module}/jobs/config/ingress/frpc.ini", {
        ip             = var.ingress_ip
        auth_token     = var.ingress_auth_token
        custom_domains = join(",", var.domains)
      })
    }
  }
  depends_on = [module.traefik_volume]
}
