data "vault_kv_secret_v2" "authelia_secrets" {
  mount = "kv"
  name  = "apps/authelia"
}

resource "nomad_job" "authelia" {
  jobspec = templatefile("${path.module}/jobs/authelia.hcl", {
    version                = "4.38.19"
    domain                 = "auth.ingress.dcentral.systems"
    ldap_address           = "ldaps://192.168.1.3:636"
    ldap_password          = data.vault_kv_secret_v2.authelia_secrets.data.ldap_password
    jwt_secret             = data.vault_kv_secret_v2.authelia_secrets.data.jwt_secret
    session_secret         = data.vault_kv_secret_v2.authelia_secrets.data.session_secret
    storage_encryption_key = data.vault_kv_secret_v2.authelia_secrets.data.storage_encryption_key
  })
}
