variable "ssh_public_key" {
  description = "SSH public key that is added to all hosts and later used to authenticate to run Ansible scripts"
  default     = "~/.ssh/id_ed25519.pub"
}
