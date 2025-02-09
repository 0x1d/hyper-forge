#--------------------------------
# Enable userpass auth method
#--------------------------------

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Add user "master"
resource "vault_generic_endpoint" "master" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/master"
  ignore_absent_fields = true
  data_json = jsonencode({
    policies = ["admins", "eaas-client"]
    password = "changeme"
  })
}
