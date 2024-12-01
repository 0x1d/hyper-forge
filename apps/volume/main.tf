# wait for NFS plugin to be available
data "nomad_plugin" "nfs" {
  plugin_id        = "nfs"
  wait_for_healthy = true
}

# create the folder on the remote host
resource "terraform_data" "nas_test_folder" {
  #triggers_replace = ...

  connection {
    host        = var.nfs.host
    port        = var.nfs.port
    user        = var.nfs.user
    private_key = var.nfs.private_key
    script_path = "/volume1/nomad/tf.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.volume.path}"
    ]
  }
}

# create the volume on Nomad
resource "nomad_csi_volume_registration" "nfs_test_volume" {
  depends_on = [data.nomad_plugin.nfs, terraform_data.nas_test_folder]

  lifecycle {
    prevent_destroy = false
  }

  plugin_id    = "nfs"
  volume_id    = var.volume.id
  external_id  = var.volume.id
  name         = var.volume.id
  capacity_min = var.volume.capacity_min
  capacity_max = var.volume.capacity_max

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  mount_options {
    fs_type     = "nfs"
    mount_flags = ["timeo=30", "intr", "vers=3", "_netdev", "nolock"]

  }

  context = {
    server           = var.nfs.host
    share            = var.volume.path
    mountPermissions = "0"
  }
}
