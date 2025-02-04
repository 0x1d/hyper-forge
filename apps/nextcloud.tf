resource "consul_node" "nextcloud" {
  name    = "nextcloud"
  address = "192.168.1.71"

  meta = {
    "external-node"  = "true"
    "external-probe" = "true"
  }
}

resource "consul_service" "nextcloud" {
  name = "nextcloud"
  node = consul_node.nextcloud.name
  port = 8080
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.nextcloud.rule=Host(`nc.dcentral.systems`)",
    "traefik.http.routers.nextcloud.tls=true",
    "traefik.http.routers.nextcloud.tls.certresolver=hetzner"
  ]

  check {
    check_id        = "service:nextcloud"
    name            = "Nextcloud health check"
    status          = "passing"
    http            = "192.168.1.71:8080"
    tls_skip_verify = true
    method          = "GET"
    interval        = "60s"
    timeout         = "5s"
  }
}
