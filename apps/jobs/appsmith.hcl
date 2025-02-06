job "appsmith" {
  datacenters = ["terra"]
  type = "service"
  
  group "appsmith" {
    max_client_disconnect  = "720h"

    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
    }

    service {
      name = "appsmith"
      port = "http"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "postgres"
              local_bind_port = 5432
            }
          }
        }
      }
    }

    volume "appsmith_data" {
      type = "csi"
      source = "${appsmith_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    task "prepare-volume" {
      driver = "docker"
      volume_mount {
        volume      = "appsmith_data"
        destination = "/appsmith-stacks"
        read_only   = false
      }
      config {
        image        = "busybox:latest"
        command      = "sh"
        args         = ["-c", "chown 0:0 /appsmith-stacks && chmod 777 /appsmith-stacks"]
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

    task "appsmith" {
      driver = "docker"
      user = "0"
      service {
        name = "appsmith-internal"
        port = "http"
        tags = ${tags}
      }
      volume_mount {
        volume = "appsmith_data"
        destination = "/appsmith-stacks"
      }
      resources {
        cpu    = 1000
        memory = 1500
      }
      env {
        TZ = "Europe/Zurich"
        APPSMITH_SIGNUP_DISABLED = true
      }
      config {
        image = "${appsmith_image}"
      }
    }

  }
}
