data_dir = "/opt/consul/data"
bind_addr = "0.0.0.0"
advertise_addr =  "{{ GetInterfaceIP `eth0` }}"
datacenter = "terra"
log_level = "INFO"
server = false
retry_join = ${servers}

addresses {
    http = "0.0.0.0"
}

ui_config {
    enabled = false
}

service {
    name = "consul"
}

connect {
  enabled = true
}

ports {
  grpc = 8502
}
