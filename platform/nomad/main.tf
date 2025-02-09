resource "nomad_job" "plugin_nfs_controller" {
  jobspec = file("${path.module}/plugins/nfs-controller.hcl")
}
resource "nomad_job" "plugin_nfs_nodes" {
  jobspec = file("${path.module}/plugins/nfs-nodes.hcl")
}
