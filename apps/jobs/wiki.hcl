job "wiki" {
  datacenters = ["terra"]
  type = "service"

  update {
    max_parallel      = 3
    health_check      = "checks"
    min_healthy_time  = "1m"
    healthy_deadline  = "10m"
    progress_deadline = "30m"
  }
  group "family" {
    max_client_disconnect  = "720h"
    
    network {
      port  "http"{
        to = 3000
      }
    }
    volume "wiki_family_data" {
      type = "csi"
      source = "${wiki_family_data_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    task "wiki" {
      driver = "docker"
      user = 1000
      env {
        TZ = "Europe/Zurich"
        DB_TYPE = "sqlite"
        DB_FILEPATH = "/wiki/data/app.db"
      }
      config {
        image = "ghcr.io/requarks/wiki:2"
        ports = ["http"]
      }
      volume_mount {
        volume = "wiki_family_data"
        destination = "/wiki/data"
      }
      resources {
        cpu    = 200
        memory = 256
      }
      service {
        name = "wiki-family"
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
