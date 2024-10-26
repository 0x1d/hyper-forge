resource "hcloud_ssh_key" "default" {
  name       = "terraform"
  public_key = file(var.ssh_public_key)
}
