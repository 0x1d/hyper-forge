data_dir  = "/opt/nomad/data"
#bind_addr = "{{ GetInterfaceIP `wg0` }}"
bind_addr = "0.0.0.0"
region = "sol"
datacenter = "terra"

server {
  enabled          = true
  bootstrap_expect = 3
}

client {
  enabled = false
}

consul {
  address = "127.0.0.1:8500"

  # The service name to register the server and client with Consul.
  server_service_name = "nomad"
  client_service_name = "nomad-client"

  # Enables automatically registering the services.
  auto_advertise = true

  # Enabling the server and client to bootstrap using Consul.
  server_auto_join = true
  client_auto_join = true
}

