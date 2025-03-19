domains = [
  "*.ingress.dcentral.systems",
  "*.k8s.ingress.dcentral.systems",
  "*.dcentral.systems"
]
machines = {
  servers = [{
    id        = 151
    name      = "citadel-1"
    ip        = "192.168.1.151"
    gateway   = "192.168.1.1"
    disk_size = 20
    cores     = 1
    memory    = 1024
    node      = "ms-01"
    }, {
    id        = 152
    name      = "citadel-2"
    ip        = "192.168.1.152"
    gateway   = "192.168.1.1"
    disk_size = 20
    cores     = 1
    memory    = 1024
    node      = "ms-01"
    }, {
    id        = 153
    name      = "citadel-3"
    ip        = "192.168.1.153"
    gateway   = "192.168.1.1"
    disk_size = 20
    cores     = 1
    memory    = 1024
    node      = "ms-01"
  }]
  clients = [{
    id        = 161
    name      = "legion-1"
    ip        = "192.168.1.161"
    gateway   = "192.168.1.1"
    disk_size = 100
    cores     = 2
    memory    = 8192
    node      = "ms-01"
    }, {
    id        = 162
    name      = "legion-2"
    ip        = "192.168.1.162"
    gateway   = "192.168.1.1"
    disk_size = 100
    cores     = 2
    memory    = 8192
    node      = "ms-01"
    }, {
    id        = 163
    name      = "legion-3"
    ip        = "192.168.1.163"
    gateway   = "192.168.1.1"
    disk_size = 100
    cores     = 2
    memory    = 8192
    node      = "ms-01"
    }, {
    id        = 164
    name      = "legion-4"
    ip        = "192.168.1.164"
    gateway   = "192.168.1.1"
    disk_size = 100
    cores     = 2
    memory    = 8192
    node      = "ms-01"
  }]
}
wireguard = {
  network         = "192.168.10.0/24"
  edge_network    = "192.168.1.0/24"
  edge_gateway_ip = "192.168.1.1"
  edge_router_ip  = "192.168.1.150"
  server_ip       = "192.168.10.1"
  router_ip       = "192.168.10.2"
  clients = [{
    name      = "oppo"
    client_ip = "192.168.10.10/32"
  },{
    name      = "pixel"
    client_ip = "192.168.10.11/32"
  },{
    name      = "gpd"
    client_ip = "192.168.10.12/32"
  }]
}
