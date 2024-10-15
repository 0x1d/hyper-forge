terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.3.1"
    }
  }
}

provider "nomad" {}

module "volumes" {
  source = "./volumes/"
}

resource "nomad_job" "nfs_test_jobs" {
  jobspec    = file("${path.module}/jobs/nfs-test.hcl")
  depends_on = [module.volumes]
}
