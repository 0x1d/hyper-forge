job "metabase" {
  datacenters = ["terra"]
  type = "service"

  group "metabase" {
    count = 1

    task "metabase" {
      driver = "docker"
      config {
        image = "metabase/metabase:v0.52.5"
        network_mode = "host"
        port_map {
          mb = 3000
        }

      }
      env {
          MB_DB_TYPE="postgres"
          MB_DB_DBNAME="metabase"
          MB_DB_PORT=5432
          MB_DB_USER="${postgres_user}"
          MB_DB_PASS="${postgres_password}"
          MB_DB_HOST="${postgres_host}"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = 500
        memory = 2048
        network {
          port  "mb"  {
            static = 3000
          }
        }
      }
      service {
        name = "metabase"
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
