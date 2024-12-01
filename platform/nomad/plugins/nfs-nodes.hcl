job "plugin-nfs-nodes" {
  datacenters = ["terra"]
  type = "system"
  group "nodes" {
    task "plugin" {
      driver = "docker"
      config {
        image = "registry.k8s.io/sig-storage/nfsplugin:v4.9.0"
        args = [
          "--v=5",
          "--nodeid=${attr.unique.hostname}",
          "--endpoint=unix:///csi/csi.sock",
          "--drivername=nfs.csi.k8s.io"
        ]
        privileged = true
      }
      csi_plugin {
        id        = "nfs"
        type      = "node"
        mount_dir = "/csi"
      }
      resources {
        memory = 50
      }
    }
  }
}
