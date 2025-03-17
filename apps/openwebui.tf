module "owui_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "owui"
    path         = "/volume1/nomad/openwebui"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}

resource "nomad_job" "owui" {
  jobspec = templatefile("${path.module}/jobs/openwebui.hcl", {
    owui_volume_id = "owui"
    tags = templatefile("${path.module}/jobs/config/ingress/traefik_tags.tpl", {
      router        = "owui"
      cert_resolver = "hetzner"
      url           = "owui.ingress.dcentral.systems"
    })
  })
  depends_on = [module.owui_volume]
}
