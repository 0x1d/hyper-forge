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
