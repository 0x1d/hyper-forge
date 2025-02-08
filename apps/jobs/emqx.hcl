job "emqx" {
  datacenters = ["terra"]
  type        = "service"

  group "emqx" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = 18083
      }
    }

    volume "emqx_data" {
      type = "csi"
      source = "${emqx_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    service {
      name = "emqx-mqtt-tcp"
      tags = ["mq"]
      port = "1883"
      connect {
        sidecar_service {}
      }
    }

    task "prepare-volume" {
      driver = "docker"
      volume_mount {
        volume      = "emqx_data"
        destination = "/data"
        read_only   = false
      }
      config {
        image        = "busybox:latest"
        command      = "sh"
        args         = ["-c", "chown -R 1000:1000 /data && chmod 777 /data"]
      }
      resources {
        cpu    = 100
        memory = 64
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }

    task "emqx" {
      driver = "docker"
      user = "1000"

      config {
        image = "${emqx_image}"
      }
      volume_mount {
        volume = "emqx_data"
        destination = "/opt/emqx/data"
      }
      resources {
        cpu    = 500
        memory = 1024
      }
      service {
        name = "emqx-internal"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}