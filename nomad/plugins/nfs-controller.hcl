job "plugin-nfs-controller" {
  datacenters = ["terra"]
  group "controller" {
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
      }
      csi_plugin {
        id        = "nfs"
        type      = "controller"
        mount_dir = "/csi"
      }
      resources {
        memory = 32
        cpu    = 100
      }
    }
  }
}
