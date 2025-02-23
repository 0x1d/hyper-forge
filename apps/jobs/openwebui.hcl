job "open-webui" {
  datacenters = ["terra"]
  type        = "service"

  group "open-webui" {
    count = 1
    network {
      mode = "bridge"
      port "http" {
        to = 8080
      }
    }
    service {
      name = "node-red"
      port = "http"
    }
    volume "owui_data" {
      type = "csi"
      source = "${owui_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    task "open-webui" {
      driver = "docker"
      config {
        image        = "ghcr.io/open-webui/open-webui:main"
        image_pull_timeout = "30m"
        ports = ["http"]
      }
      volume_mount {
        volume = "owui_data"
        destination = "/app/backend/data"
      }
      resources {
        cpu    = 500
        memory = 2048
      }
      service {
        name = "owui-internal"
        port = "http"
        tags = ${tags}
      }
    }
  }
}