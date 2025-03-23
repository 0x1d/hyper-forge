module "wiki_family_data_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "wiki-family-data"
    path         = "/volume1/nomad/wiki/family"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}

resource "nomad_job" "wiki" {
  jobspec = templatefile("${path.module}/jobs/wiki.hcl", {
    wiki_family_data_volume_id = "wiki-family-data"
    tags = templatefile("${path.module}/jobs/config/ingress/traefik_tags.tpl", {
      router        = "bork"
      cert_resolver = "hetzner"
      url           = "bork.ingress.dcentral.systems"
    })
  })
  depends_on = [module.wiki_family_data_volume]
}
