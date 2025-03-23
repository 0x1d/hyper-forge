module "nodered_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "node-red"
    path         = "/volume1/nomad/node-red"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}

resource "nomad_job" "nodered" {
  jobspec = templatefile("${path.module}/jobs/flows.hcl", {
    nodered_volume_id = "node-red"
    nodered_image     = "nodered/node-red:4.0.8-22"
    tags = templatefile("${path.module}/jobs/config/ingress/traefik_auth_tags.tpl", {
      router        = "flows"
      cert_resolver = "hetzner"
      url           = "flows.dcentral.systems"
    })
  })
  depends_on = [module.nodered_volume]
}
