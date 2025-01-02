locals {
  postgres = {
    user     = "postgres"
    password = "postgres"
    database = "postgres"
    volume   = "postgres-volume"
  }
  pgadmin = {
    email    = "admin@dcentral.systems"
    password = "password"
  }
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
    postgres_password  = local.postgres.password
    postgres_volume_id = local.postgres.volume
    postgres_database  = local.postgres.database
    pgadmin_email      = local.pgadmin.email
    pgadmin_password   = local.pgadmin.password
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
    postgres_password = local.postgres.password
    postgres_host     = "postgres.service.consul"
  })
  depends_on = [nomad_job.postgres]
}
