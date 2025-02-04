terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.3.1"
    }
  }
}

provider "nomad" {}

resource "nomad_job" "plugin_nfs_controller" {
  jobspec = file("${path.module}/plugins/nfs-controller.hcl")
}
resource "nomad_job" "plugin_nfs_nodes" {
  jobspec = file("${path.module}/plugins/nfs-nodes.hcl")
}

resource "nomad_job" "ingress" {
  jobspec = file("${path.module}/jobs/ingress.hcl")
  hcl2 {
    vars = {
      dns_api_key  = var.dns_api_key
      traefik_toml = file("${path.module}/jobs/config/traefik.toml")
      frpc_ini = templatefile("${path.module}/jobs/config/frpc.ini", {
        ip             = var.ingress_config.ip
        auth_token     = var.ingress_config.auth_token
        custom_domains = join(",", var.ingress_config.custom_domains)
      })

    }
  }
}
