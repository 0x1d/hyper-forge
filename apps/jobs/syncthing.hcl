job "syncthing" {
  datacenters = ["terra"]
  type = "service"
  update {
    max_parallel      = 3
    health_check      = "checks"
    min_healthy_time  = "1m"
    healthy_deadline  = "10m"
    progress_deadline = "30m"
  }
  group "syncthing" {
    max_client_disconnect  = "720h"
    count = 1

    network {
      mode = "bridge"
      port  "http"{
        to = 8384
      }
      port "listen" {
        static = 22000
      }
      port "discovery" {
        static = 21027
      }
    }
    #service {
    #  name = "syncthing"
    #  port = "http"
    #}
    volume "syncthing_data" {
      type = "csi"
      source = "${syncthing_data_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    volume "syncthing_config" {
      type = "csi"
      source = "${syncthing_config_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    task "prepare-volume" {
      driver = "docker"
      volume_mount {
        volume      = "syncthing_data"
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
    task "syncthing" {
      driver = "docker"

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "Europe/Zurich"
      }
      config {
        image = "lscr.io/linuxserver/syncthing:latest"
        #volumes = [
        #  "/mnt/gluster/public:/public",
        #  "/mnt/gluster/config/syncthing:/config"
        #]

      }
      volume_mount {
        volume = "syncthing_data"
        destination = "/public"
      }
      volume_mount {
        volume = "syncthing_config"
        destination = "/config"
      }
      service {
        name = "syncthing"
        port = "http"
        tags = ${tags}
      }
      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
