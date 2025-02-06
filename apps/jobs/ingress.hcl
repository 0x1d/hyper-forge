variable  "frpc_ini" {
  type = string
  default = ""
}

variable  "traefik_toml" {
  type = string
  default = ""
}

variable "dns_api_key" {
  type = string
  default = ""
}
variable "traefik_volume_id" {
  type = string
  default = "traefik"
}

job "ingress" {
  datacenters = ["terra"]
  type        = "service"
  update {
    max_parallel     = 1
    min_healthy_time = "30s"
    healthy_deadline = "10m"
    progress_deadline = "15m"
  }
  group "web" {
    count = 1
    max_client_disconnect  = "720h"

    volume "traefik_data" {
      type = "csi"
      source = var.traefik_volume_id
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }


    network {
      port "http" {
        static = 8080
      }
      port "https" {
        static = 8443
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
      
    }

    task "prepare-volume" {
      driver = "docker"
      volume_mount {
        volume      = "traefik_data"
        destination = "/traefik"
        read_only   = false
      }
      config {
        image        = "busybox:latest"
        command      = "sh"
        args         = ["-c", "chown 0:0 /traefik && chmod 777 /traefik"]
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

    task "proxy" {
      driver = "docker"
      config {
        image = "wirelos/frpc:0.61.1"
        network_mode = "host"
        args    = ["-c", "/etc/frp/frpc.ini"]
        volumes = [
          "local/frpc.ini:/etc/frp/frpc.ini"
        ]
      }

      template {
        data = var.frpc_ini
				destination = "local/frpc.ini"
      }
    }


    task "traefik" {
      driver = "docker"
      user = "0"
      env {
        HETZNER_API_KEY = var.dns_api_key
      }
      config {
        image        = "traefik:3.2"
        network_mode = "host"
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }
      volume_mount {
        volume = "traefik_data"
        destination = "/traefik"
      }
      template {
        data = var.traefik_toml
        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 200
      }
    }
  }
}
