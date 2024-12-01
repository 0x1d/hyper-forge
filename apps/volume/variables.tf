variable "nfs" {
  type = object({
    host        = string
    port        = number
    user        = string
    private_key = string
  })
}

variable "volume" {
  type = object({
    path         = string
    id           = string
    capacity_min = string
    capacity_max = string
  })
}

variable "nfs_script_path" {
  default = "/volume1/nomad/tf.sh"
}
