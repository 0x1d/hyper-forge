module "emqx_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "emqx"
    path         = "/volume1/nomad/emqx"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}

resource "nomad_job" "emqx" {
  jobspec = templatefile("${path.module}/jobs/emqx.hcl", {
    emqx_volume_id = "emqx"
    emqx_image     = "emqx/emqx:latest"
  })
  depends_on = [module.emqx_volume]
}
