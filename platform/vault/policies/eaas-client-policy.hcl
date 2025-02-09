# Permits CRUD operation on key-value store
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# List enabled secrets engines
path "secret/metadata/*" {
   capabilities = ["list"]
}
