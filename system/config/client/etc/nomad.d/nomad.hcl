data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"
region = "sol"
datacenter = "terra"

client {
  enabled = true
  cni_path = "/opt/cni/bin"
}

consul {
  address = "127.0.0.1:8500"
  client_service_name = "nomad-client"
  auto_advertise = true
  client_auto_join = true
}

plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"
    volumes {
        enabled = true
        selinuxlabel = "z"
    }
    allow_privileged = true
  }
}
