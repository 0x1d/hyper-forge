job "appsmith" {
  datacenters = ["terra"]
  type = "service"
  
  group "appsmith" {
    max_client_disconnect  = "720h"
    
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
        name = "appsmith"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
        #tags = [
        #  "traefik.enable=true",
        #  "traefik.http.routers.appsmith.rule=Host(`....`)",
        #  "traefik.http.routers.appsmith.tls=true",
        #  "traefik.http.routers.appsmith.tls.certresolver=hetzner",
        #  "traefik.http.middlewares.appsmith-auth.basicauth.users=...",
        #  "traefik.http.routers.appsmith.middlewares=appsmith-auth"
        #]
      }
      volume_mount {
        volume = "appsmith_data"
        destination = "/appsmith-stacks"
      }
      resources {
        cpu    = 1000
        memory = 1500
        network {
          port "http" {
            static = 80 # or map to 8080 and comment out network_mode
          }
        }
      }
      env {
        TZ = "Europe/Zurich"
      }
      config {
        image = "${appsmith_image}"
        network_mode = "host"
        port_map {
          http = 80
        }
      }
    }

  }
}
