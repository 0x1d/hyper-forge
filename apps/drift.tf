data "vault_kv_secret_v2" "drift_secrets" {
  mount = "kv"
  name  = "apps/solana"
}

resource "nomad_job" "drift" {
  jobspec = templatefile("${path.module}/jobs/drift.hcl", {
    drift_config          = templatefile("${path.module}/jobs/config/drift/config.yaml", {})
    rpc_endpoint          = data.vault_kv_secret_v2.drift_secrets.data.rpc_endpoint
    bot_private_key       = data.vault_kv_secret_v2.drift_secrets.data.bot_private_key
    jito_private_key      = data.vault_kv_secret_v2.drift_secrets.data.jito_private_key
    jito_block_engine_url = "frankfurt.mainnet.block-engine.jito.wtf"
  })
}
