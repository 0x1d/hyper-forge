variable "dns_api_key" {
  description = "API key for DNS provider"
}

variable "ingress_config" {
  type = object({
    auth_token     = string
    ip             = string
    custom_domains = list(string)
  })
}
