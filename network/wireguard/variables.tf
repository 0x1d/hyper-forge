variable "edge" {
  type = object({
    network = string
  })
}

variable "cloud" {
  type = object({
    network = string
  })
}

variable "clients" {
  type = list(object({
    name      = string
    client_ip = string
  }))
}

variable "wireguard" {
  type = object({
    network          = string
    server_ip        = string
    server_public_ip = string
    router_ip        = string
  })
  default = {
    network          = "192.168.10.0/24"
    server_ip        = "192.168.10.1/32"
    server_public_ip = ""
    router_ip        = "192.168.10.2/32"
  }
}
