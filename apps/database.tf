locals {
  postgres = {
    user     = "postgres"
    database = "postgres"
    volume   = "postgres-volume"
  }
  pgadmin = {
    email = "admin@dcentral.systems"
  }
}

data "vault_kv_secret_v2" "postgres_secrets" {
  mount = "kv"
  name  = "apps/postgres"
}

module "postgres_volume" {
  source = "./volume/"
  nfs    = local.nfs
  volume = {
    id           = local.postgres.volume
    path         = "/volume1/nomad/postgres"
    capacity_min = "10GiB"
    capacity_max = "20GiB"
  }
}

resource "nomad_job" "postgres" {
  jobspec = templatefile("${path.module}/jobs/postgres.hcl", {
    postgres_user      = local.postgres.user
    postgres_password  = data.vault_kv_secret_v2.postgres_secrets.data.POSTGRES_PASSWORD
    postgres_volume_id = local.postgres.volume
    postgres_database  = local.postgres.database
    pgadmin_email      = local.pgadmin.email
    pgadmin_password   = data.vault_kv_secret_v2.postgres_secrets.data.PGADMIN_PASSWORD
  })
  depends_on = [module.postgres_volume]
}

#resource "nomad_job" "pgadmin4" {
#  jobspec = templatefile("${path.module}/jobs/pgadmin4.hcl", {
#    postgres_user     = local.postgres.user
#    postgres_password = local.postgres.password
#    postgres_database = local.postgres.database
#    pgadmin_email     = local.pgadmin.email
#    pgadmin_password  = local.pgadmin.password
#  })
#  depends_on = [nomad_job.postgres]
#}

resource "nomad_job" "metabase" {
  jobspec = templatefile("${path.module}/jobs/metabase.hcl", {
    postgres_user     = local.postgres.user
    postgres_password = data.vault_kv_secret_v2.postgres_secrets.data.POSTGRES_PASSWORD
    postgres_host     = "postgres.service.consul"
    tags = templatefile("${path.module}/jobs/config/ingress/traefik_tags.tpl", {
      router        = "metabase"
      cert_resolver = "hetzner"
      url           = "metabase.ingress.dcentral.systems"
    })
  })
  depends_on = [nomad_job.postgres]
}
