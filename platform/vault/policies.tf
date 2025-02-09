#---------------------
# Create policies
#---------------------

# Create admin policy in the root namespace
resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("${path.module}/policies/admin-policy.hcl")
}

resource "vault_policy" "eaas-client" {
  name   = "eaas-client"
  policy = file("${path.module}/policies/eaas-client-policy.hcl")
}
