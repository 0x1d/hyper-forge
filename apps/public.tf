resource "nomad_job" "public" {
  jobspec = templatefile("${path.module}/jobs/public.hcl", {
    syncthing_data_volume_id = "syncthing-data"
    tags = templatefile("${path.module}/jobs/config/ingress/traefik_auth_tags.tpl", {
      router        = "public-files"
      cert_resolver = "hetzner"
      url           = "files.dcentral.systems"
    })
  })
  depends_on = [module.syncthing_data_volume]
}
