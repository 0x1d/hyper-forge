job "nfs-test" {
  datacenters = ["terra"]
  type = "service"
  group "server" {
    count = 1
    volume "test" {
      type = "csi"
      source = "nas-test"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    task "server" {
      driver = "docker"
      config {
        image = "alpine"
        args  = ["sleep", "3600"]
      }
      volume_mount {
        volume = "test"
        destination = "/mnt/test"
      }
    }
  }
}

