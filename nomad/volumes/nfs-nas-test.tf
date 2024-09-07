# It can sometimes be helpful to wait for a particular plugin to be available
data "nomad_plugin" "nfs" {
  plugin_id        = "nfs"
  wait_for_healthy = true
}

 # create the folder on the remote host
resource "terraform_data" "nas_test_folder" {
  #triggers_replace = ...

  connection {
    host = "192.168.1.3"
    user = "master"
    private_key = file("~/.ssh/id_ed25519")
    script_path = "/volume1/nomad/tf.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /volume1/nomad/test"
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
  volume_id    = "nas-test"
  external_id  = "nas-test"
  name         = "nas-test"
  capacity_min = "10GiB"
  capacity_max = "20GiB"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  mount_options {
    fs_type = "nfs"
    mount_flags = [ "timeo=30", "intr", "vers=3", "_netdev" , "nolock" ]

  }


  context = {
    server = "192.168.1.3"
    share = "/volume1/nomad/test"
    mountPermissions = "0"
  }
}
