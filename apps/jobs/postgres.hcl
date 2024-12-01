#To Configure vault
# vault secrets enable database
# vault write database/config/postgresql  plugin_name=postgresql-database-plugin   connection_url="postgresql://{{username}}:{{password}}@postgres.service.consul:5432/postgres?sslmode=disable"   allowed_roles="*"     username="root"     password="rootpassword"
# vault write database/roles/readonly db_name=postgresql     creation_statements=@readonly.sql     default_ttl=1h max_ttl=24h

job "database" {
  datacenters = ["terra"]
  type = "service"

  group "postgres" {
    count = 1

    volume "pgdata" {
      type = "csi"
      source = "${postgres_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres:17"
        network_mode = "host"
        port_map {
          db = 5432
        }

      }
      env {
          POSTGRES_USER="${postgres_user}"
          POSTGRES_PASSWORD="${postgres_password}"
          PGDATA="/var/lib/postgresql/data/pgdata"
      }

      volume_mount {
        volume = "pgdata"
        destination = "/var/lib/postgresql/data/pgdata"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = 500
        memory = 512
        network {
          port  "db"  {
            static = 5432
          }
        }
      }
      service {
        name = "postgres"
        tags = ["postgres", "database"]
        port = "db"

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
