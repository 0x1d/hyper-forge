data_dir = "/opt/consul/data"
bind_addr = "{{ GetInterfaceIP `eth0` }}"
advertise_addr =  "{{ GetInterfaceIP `eth0` }}"
datacenter = "terra"
bootstrap_expect = 3
log_level = "INFO"
server = true
retry_join = ${servers}

addresses {
    http = "0.0.0.0"
    grpc = "0.0.0.0"
}
ui_config {
    enabled = true
}

service {
    name = "consul"
}

connect {
  enabled = true
}

ports {
  grpc = 8502
#  serf_lan = 9301
}
