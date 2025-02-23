job "flows" {
  datacenters = ["terra"]
  type = "service"
  group "node-red" {
    max_client_disconnect  = "720h"

    network {
      mode = "bridge"
      port "http" {
        to = 1880
      }
    }
    service {
      name = "node-red"
      port = "http"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "postgres"
              local_bind_port = 5432
            }
            upstreams {
              destination_name = "mqtt-tcp"
              local_bind_port = 1883
            }
          }
        }
      }
    }
    volume "nodered_data" {
      type = "csi"
      source = "${nodered_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    task "prepare-volume" {
      driver = "docker"
      volume_mount {
        volume      = "nodered_data"
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

    task "node-red" {
      driver = "docker"
      user = "1000"
      service {
        name = "node-red"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
      volume_mount {
        volume = "nodered_data"
        destination = "/data"
      }
      resources {
        cpu    = 500
        memory = 256
      }
      env {
        TZ = "Europe/Zurich"
      }
      config {
        image = "${nodered_image}"
      }
    }

  }
}
