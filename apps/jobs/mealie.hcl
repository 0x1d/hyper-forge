job "mealie" {
  datacenters = ["terra"]
  type = "service"

  update {
    max_parallel      = 3
    health_check      = "checks"
    min_healthy_time  = "1m"
    healthy_deadline  = "10m"
    progress_deadline = "30m"
  }
  group "mealie" {
    max_client_disconnect  = "720h"
    
    network {
      port  "http"{
        to = 9000
      }
    }
    volume "mealie_data" {
      type = "csi"
      source = "${mealie_data_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    task "h5ai" {
      driver = "docker"
      env {
        PUID = 1000
        PGID = 1000
        ALLOW_SIGNUP = true
        TZ = "Europe/Zurich"
        MAX_WORKERS = 1
        WEB_CONCURRENCY = 1
        BASE_URL = "https://mealie.ingress.dcentral.systems"
      }
      config {
        image = "ghcr.io/mealie-recipes/mealie:v1.0.0-RC1.1"
        ports = ["http"]
      }
      volume_mount {
        volume = "mealie_data"
        destination = "/app/data"
      }
      resources {
        cpu    = 200
        memory = 256
      }
      service {
        name = "mealie"
        port = "http"
        
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "10s"
        }
        tags = ${tags}
      }
      kill_timeout = "30m"
    }

  }
}
