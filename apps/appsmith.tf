module "appsmith_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "appsmith"
    path         = "/volume1/nomad/appsmith"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}

resource "nomad_job" "appsmith" {
  jobspec = templatefile("${path.module}/jobs/appsmith.hcl", {
    appsmith_volume_id = "appsmith"
    appsmith_image     = "index.docker.io/appsmith/appsmith-ce:v1.8.15"
    #appsmith_image = "index.docker.io/appsmith/appsmith-ce:v1.54"
  })
  depends_on = [module.appsmith_volume]
}
