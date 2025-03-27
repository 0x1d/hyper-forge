job "drift" {
  datacenters = ["terra"]
  type = "service"
  group "keeper" {
    max_client_disconnect  = "720h"
    
    task "bot" {
      driver = "docker"
      env {
        PUID = 1000
        PGID = 1000
        ENDPOINT = "${rpc_endpoint}"
        KEEPER_PRIVATE_KEY = "${bot_private_key}"
        JITO_BLOCK_ENGINE_URL = "${jito_block_engine_url}"
        JITO_AUTH_PRIVATE_KEY = "${jito_private_key}"
      }
      config {
        image = "wirelos/drift-keeper:mainnet-beta"
        command = "node"
        args = [ "./lib/index.js", "--config-file=/local/config.yaml"]
      }
      resources {
        cpu    = 2000
        memory = 2048
      }
      template {
        data = <<-EOF
${drift_config}
EOF
        destination = "local/config.yaml"
        env         = false
      }
    }
  }
}
