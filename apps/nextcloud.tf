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
}
