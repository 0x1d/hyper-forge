resource "consul_node" "kiwix" {
  name    = "kiwix"
  address = "192.168.1.3"

  meta = {
    "external-node"  = "true"
    "external-probe" = "true"
  }
}

resource "consul_service" "kiwix" {
  name = "kiwix"
  node = consul_node.kiwix.name
  port = 8080
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.kiwix.rule=Host(`kiwix.dcentral.systems`)",
    "traefik.http.routers.kiwix.tls=true",
    "traefik.http.routers.kiwix.tls.certresolver=hetzner",
    "traefik.http.routers.kiwix.middlewares=authelia@consulcatalog"
  ]
}
