job "flows" {
  datacenters = ["terra"]
  type = "service"
  group "node-red" {
    max_client_disconnect  = "720h"
    
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
        #tags = [
        #  "traefik.enable=true",
        #  "traefik.http.routers.nodered.rule=Host(`....`)",
        #  "traefik.http.routers.nodered.tls=true",
        #  "traefik.http.routers.nodered.tls.certresolver=hetzner",
        #  "traefik.http.middlewares.nodered-auth.basicauth.users=...",
        #  "traefik.http.routers.nodered.middlewares=nodered-auth"
        #]
      }
      volume_mount {
        volume = "nodered_data"
        destination = "/data"
      }
      resources {
        cpu    = 500
        memory = 256
        network {
          port "http" {
            static = 1880
          }
        }
      }
      env {
        TZ = "Europe/Zurich"
      }
      config {
        image = "${nodered_image}"
        network_mode = "host"
        port_map {
          http = 1880
        }
      }
    }

  }
}
