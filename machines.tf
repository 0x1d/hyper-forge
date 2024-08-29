locals {
  servers = [{
    id = 151
    name = "hf-server-1"
    ip = "192.168.1.151"
    gateway = "192.168.1.1"
    disk_size = 20
    cores = 1
    memory = 1024
  },{
    id = 152
    name = "hf-server-2"
    ip = "192.168.1.152"
    gateway = "192.168.1.1"
    disk_size = 20
    cores = 1
    memory = 1024
  },{
    id = 153
    name = "hf-server-3"
    ip = "192.168.1.153"
    gateway = "192.168.1.1"
    disk_size = 20
    cores = 1
    memory = 1024
  }]
  clients = [{
    id = 161
    name = "hf-client-1"
    ip = "192.168.1.161"
    gateway = "192.168.1.1"
    disk_size = 100
    cores = 2
    memory = 2048
  }]
}
