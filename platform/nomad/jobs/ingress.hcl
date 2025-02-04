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

      env {
        HETZNER_API_KEY = var.dns_api_key
      }
      config {
        image        = "traefik:3.2"
        network_mode = "host"
        volumes = [
          "/var/traefik/letsencrypt:/letsencrypt",
          "/var/traefik/hetzner:/hetzner",
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
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
