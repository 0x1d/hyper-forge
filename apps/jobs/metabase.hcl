job "metabase" {
  datacenters = ["terra"]
  type = "service"

  group "metabase" {
    count = 1

    network {
      mode = "bridge"
      port "mb" {
        to = 3000
      }
    }

    service {
      name = "metabase"
      port = "mb"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "postgres"
              local_bind_port = 5432
            }
          }
        }
      }
    }

    task "metabase" {
      driver = "docker"
      config {
        image = "metabase/metabase:v0.52.5"
      }
      env {
          MB_DB_TYPE="postgres"
          MB_DB_DBNAME="metabase"
          MB_DB_HOST="localhost"
          MB_DB_PORT=5432
          MB_DB_USER="${postgres_user}"
          MB_DB_PASS="${postgres_password}"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = 500
        memory = 2048
      }
      service {
        name = "metabase-internal"
        port = "mb"
        enable_tag_override = true
        tags = ${tags}

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

  }

  update {
    max_parallel = 1
    min_healthy_time = "5s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }
}
