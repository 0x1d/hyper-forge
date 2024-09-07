terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.3.1"
    }
  }
}

provider "nomad" {
}

resource "nomad_job" "plugin_nfs_controller" {
  jobspec = file("${path.module}/plugins/nfs-controller.hcl")
}
resource "nomad_job" "plugin_nfs_nodes" {
  jobspec = file("${path.module}/plugins/nfs-nodes.hcl")
}

module "volumes" {
  source = "./volumes/"
  depends_on = [ nomad_job.plugin_nfs_nodes, nomad_job.plugin_nfs_controller ]
}

resource "nomad_job" "nfs_test_jobs" {
  jobspec = file("${path.module}/jobs/nfs-test.hcl")
  depends_on = [ module.volumes ]
}

