data "vault_kv_secret_v2" "desktop_secrets" {
  mount = "kv"
  name  = "apps/desktop"
}

module "desktop_data_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = "desktop-volume"
    path         = "/volume1/nomad/desktop"
    capacity_min = "1GiB"
    capacity_max = "5GiB"
  }
}

resource "nomad_job" "desktop" {
  jobspec = templatefile("${path.module}/jobs/desktop.hcl", {
    data_volume_id = "desktop-volume"
    vnc_password   = data.vault_kv_secret_v2.desktop_secrets.data.vnc_password
    basic_auth     = base64encode("kasm_user:${data.vault_kv_secret_v2.desktop_secrets.data.vnc_password}")
  })
  depends_on = [module.desktop_data_volume]
}
