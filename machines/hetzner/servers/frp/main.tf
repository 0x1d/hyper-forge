variable "ip" {}
variable "frps_subdomain_host"{}
variable "frps_port" {}
variable "frps_auth_token" {}
variable "frps_image" {
  default = "wirelos/frps:0.46.1-amd64"
}
variable "proxy_ports" {
  default =  ["2222", "7000"]
}

# ---------------------------------------------------------------------
# frpc.ini
# Configuration file for frp-client
# ---------------------------------------------------------------------
data "template_file" "frpc_ini" {
  template = file("${path.module}/frpc.ini")
  vars = {
    auth_token = var.frps_auth_token
    ip         = var.ip
  }
}

output "client_config" {
  sensitive = true
  value     = data.template_file.frpc_ini.rendered
}

# ---------------------------------------------------------------------
# frps.ini
# Configuration file for frp-server
# ---------------------------------------------------------------------
data "template_file" "frps_ini" {
  template = file("${path.module}/frps.ini")
  vars = {
    frps_subdomain_host = var.frps_subdomain_host
    frps_token          = var.frps_auth_token
    frps_port           = var.frps_port
  }
}

output "server_config" {
  sensitive = true
  value     = data.template_file.frps_ini.rendered
}

# ---------------------------------------------------------------------
# cloud-config
# Cloud-Init configuration passed to user-data and run on first boot
# ---------------------------------------------------------------------
data "template_file" "cloud_init" {
  template = file("${path.module}/cloud-config.yaml")
  vars = {
    frps_ini   = base64encode(data.template_file.frps_ini.rendered)
    frps_image = var.frps_image
    ports      = join(" ", [for port in var.proxy_ports : "-p ${port}:${port}"])
  }
}

data "cloudinit_config" "conf" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
    filename     = "conf.yaml"
  }
}

output "cloud_config" {
  sensitive = true
  value     = data.cloudinit_config.conf.rendered
}
