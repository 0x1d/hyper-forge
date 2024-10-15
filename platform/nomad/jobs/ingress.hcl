#variable  "frpc_ini" {
#  type = string
#  default = ""
#}

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
        static = 80
      }
      port "https" {
        static = 443
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

    #task "proxy" {
    #  driver = "raw_exec"
    #  artifact {
    #    source      = "https://github.com/fatedier/frp/releases/download/v0.46.1/frp_0.46.1_linux_arm64.tar.gz"
    #    destination = "local/frp"
    #    options {
    #      checksum = "sha256:76e5d42d4d2971de51de652417cfe38461ef9e18672e1070a1138910c8448a2f"
    #    }
    #  }
    #  config {
    #    command = "local/frp/frp_0.46.1_linux_arm64/frpc"
    #    args    = ["-c", "local/frpc.ini"]
    #  }
    #  template {
    #    data = var.frpc_ini
		#		destination = "local/frpc.ini"
    #  }
    #}

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

      #resources {
      #  cpu    = 100
      #  memory = 128
      #}
    }
  }
}
