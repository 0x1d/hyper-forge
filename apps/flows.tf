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
    nodered_image     = "nodered/node-red:4.0.5-22"
  })
  depends_on = [module.nodered_volume]
}