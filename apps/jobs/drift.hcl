job "drift" {
  datacenters = ["terra"]
  type = "service"
  group "metrics" {
    network {
      port  "http"{
        to = 3000
      }
    }
    task "metrics" {
      driver = "docker"
      env {
        PRIVATE_KEY = "${bot_private_key}"
        RPC_ENDPOINT = "${rpc_endpoint}"
      }
      config {
        image = "wirelos/drift-metrics"
        ports = ["http"]
      }
      resources {
        cpu    = 200
        memory = 200
      }
      service {
        name = "drift-metrics"
        port = "http"
      }
    }
  }
  group "keeper" {
    count = 5
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
        force_pull = true
      }
      resources {
        cpu    = 500
        memory = 500
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
