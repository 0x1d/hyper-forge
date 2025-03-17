job "public" {
  datacenters = ["terra"]
  type = "service"

  update {
    max_parallel      = 3
    health_check      = "checks"
    min_healthy_time  = "1m"
    healthy_deadline  = "10m"
    progress_deadline = "30m"
  }
  group "files" {
    max_client_disconnect  = "720h"
    
    network {
      port  "http"{
        to = 80
      }
    }
    volume "syncthing_data" {
      type = "csi"
      source = "${syncthing_data_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    task "h5ai" {
      driver = "docker"
      env {
        PUID = 1000
        PGID = 1000
      }
      config {
        image = "awesometic/h5ai"
        ports = ["http"]
      }
      volume_mount {
        volume = "syncthing_data"
        destination = "/h5ai"
      }
      resources {
        cpu    = 200
        memory = 256
      }
      service {
        name = "files"
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
