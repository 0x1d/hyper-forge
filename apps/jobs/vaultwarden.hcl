job "vaultwarden" {
  datacenters = ["terra"]
  type = "service"
  group "vaultwarden" {
    max_client_disconnect  = "720h"
    
    network {
      port "http" {
        to = 80
      }
    }
      
    volume "vaultwarden_data" {
      type = "csi"
      source = "${vaultwarden_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    task "prepare-volume" {
      driver = "docker"
      volume_mount {
        volume      = "vaultwarden_data"
        destination = "/data"
        read_only   = false
      }
      config {
        image        = "busybox:latest"
        command      = "sh"
        args         = ["-c", "chown -R 0:0 /data && chmod 777 /data"]
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

    task "vaultwarden" {
      driver = "docker"
      user = "0"
      service {
        name = "vaultwarden"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
        tags = ${tags}
      }
      volume_mount {
        volume = "vaultwarden_data"
        destination = "/data"
      }
      resources {
        cpu    = 500
        memory = 256
      }
      env {
        TZ = "Europe/Zurich"
        WEBSOCKET_ENABLED = true
        ADMIN_TOKEN = "${vaultwarden_admin_token}"
        SIGNUPS_ALLOWED = false
      }
      config {
        image = "${vaultwarden_image}"
        ports = ["http"]
      }
    }

  }
}
