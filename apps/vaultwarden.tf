data "vault_kv_secret_v2" "vaultwarden_secrets" {
  mount = "kv"
  name  = "apps/vaultwarden"
}


module "vaultwarden_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "vaultwarden"
    path         = "/volume1/nomad/vaultwarden"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}

resource "nomad_job" "vaultwarden" {
  jobspec = templatefile("${path.module}/jobs/vaultwarden.hcl", {
    vaultwarden_volume_id   = "vaultwarden"
    vaultwarden_image       = "vaultwarden/server:1.33.1"
    vaultwarden_admin_token = data.vault_kv_secret_v2.vaultwarden_secrets.data.ADMIN_TOKEN
    tags = templatefile("${path.module}/jobs/traefik_tags.tpl", {
      router        = "vaultwarden"
      cert_resolver = "hetzner"
      url           = "vaultwarden.ingress.dcentral.systems"
    })
  })
  depends_on = [module.vaultwarden_volume]
}
