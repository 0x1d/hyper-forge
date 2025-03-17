module "syncthing_data_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "syncthing-data"
    path         = "/volume1/nomad/syncthing-data"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}
module "syncthing_config_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "syncthing-config"
    path         = "/volume1/nomad/syncthing-config"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}
resource "nomad_job" "syncthing" {
  jobspec = templatefile("${path.module}/jobs/syncthing.hcl", {
    syncthing_data_volume_id   = "syncthing-data"
    syncthing_config_volume_id = "syncthing-config"
    tags = templatefile("${path.module}/jobs/config/ingress/traefik_auth_tags.tpl", {
      router        = "syncthing"
      cert_resolver = "hetzner"
      url           = "sync.ingress.dcentral.systems"
    })
  })
  depends_on = [module.syncthing_data_volume, module.syncthing_config_volume]
}
