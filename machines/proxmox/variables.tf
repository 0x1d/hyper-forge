variable "image" {
  type    = string
  default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "ssh_key" {
  type = string
}

variable "machines" {
  type = list(object({
    id        = number
    name      = string
    ip        = string
    gateway   = string
    disk_size = number
    cores     = number
    memory    = number
  }))
  default = []
}

variable "wireguard" {

}
