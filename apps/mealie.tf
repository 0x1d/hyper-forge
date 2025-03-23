module "mealie_data_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "mealie-data"
    path         = "/volume1/nomad/mealie"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}

resource "nomad_job" "mealie" {
  jobspec = templatefile("${path.module}/jobs/mealie.hcl", {
    mealie_data_volume_id = "mealie-data"
    tags = templatefile("${path.module}/jobs/config/ingress/traefik_tags.tpl", {
      router        = "mealie"
      cert_resolver = "hetzner"
      url           = "mealie.dcentral.systems"
    })
  })
  depends_on = [module.mealie_data_volume]
}
