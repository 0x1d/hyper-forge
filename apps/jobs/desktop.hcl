job "desktop" {
  datacenters = ["terra"]
  type = "service"

  update {
    max_parallel      = 3
    health_check      = "checks"
    min_healthy_time  = "1m"
    healthy_deadline  = "10m"
    progress_deadline = "30m"
  }
  group "parrot-os" {
    max_client_disconnect  = "720h"
    
    network {
      port  "http"{
        to = 6901
      }
    }
    volume "data" {
      type = "csi"
      source = "${data_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    task "parrot-os" {
      driver = "docker"
      user = "0"
      env {
        PUID = 1000
        PGID = 1000
        VNC_PW = "${vnc_password}"
      }
      config {
        image = "kasmweb/parrotos-6-desktop:1.16.1"
        ports = ["http"]
      }
      volume_mount {
        volume = "data"
        destination = "/home/kasm-user/data"
      }
      resources {
        cpu    = 1000
        memory = 2048
      }
      service {
        name = "parrot"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.services.parrotos.loadbalancer.server.scheme=https",
          "traefik.http.routers.parrot-os.rule=Host(`parrot.ingress.dcentral.systems`)",
          "traefik.http.routers.parrot-os.service=parrotos",
          "traefik.http.routers.parrot-os.tls=true",
          "traefik.http.routers.parrot-os.tls.certresolver=hetzner",
          "traefik.http.routers.parrot-os.middlewares=authelia@consulcatalog,basicAuthParrotOS",
          "traefik.http.middlewares.basicAuthParrotOS.headers.customrequestheaders.Authorization=Basic ${basic_auth}"
        ]
      }
      kill_timeout = "30m"
    }
  }
  group "debian" {
    max_client_disconnect  = "720h"
    
    network {
      port  "http"{
        to = 6901
      }
    }
    volume "data" {
      type = "csi"
      source = "${data_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    task "debian" {
      driver = "docker"
      user = "0"
      env {
        PUID = 1000
        PGID = 1000
        VNC_PW = "${vnc_password}"
      }
      config {
        image = "kasmweb/core-debian-bookworm:1.16.0"
        ports = ["http"]
      }
      volume_mount {
        volume = "data"
        destination = "/home/kasm-user/data"
      }
      resources {
        cpu    = 1000
        memory = 2048
      }
      service {
        name = "debian"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.services.debian.loadbalancer.server.scheme=https",
          "traefik.http.routers.debian.rule=Host(`debian.ingress.dcentral.systems`)",
          "traefik.http.routers.debian.service=debian",
          "traefik.http.routers.debian.tls=true",
          "traefik.http.routers.debian.tls.certresolver=hetzner",
          "traefik.http.routers.debian.middlewares=authelia@consulcatalog,basicAuthDebian",
          "traefik.http.middlewares.basicAuthDebian.headers.customrequestheaders.Authorization=Basic ${basic_auth}"
        ]
      }
      kill_timeout = "30m"
    }
  }
}
