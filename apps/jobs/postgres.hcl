#To Configure vault
# vault secrets enable database
# vault write database/config/postgresql  plugin_name=postgresql-database-plugin   connection_url="postgresql://{{username}}:{{password}}@postgres.service.consul:5432/postgres?sslmode=disable"   allowed_roles="*"     username="root"     password="rootpassword"
# vault write database/roles/readonly db_name=postgresql     creation_statements=@readonly.sql     default_ttl=1h max_ttl=24h

job "database" {
  datacenters = ["terra"]
  type = "service"

  group "postgres" {
    count = 1

    network {
      mode = "bridge"
    }

    volume "pgdata" {
      type = "csi"
      source = "${postgres_volume_id}"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    service {
      name = "postgres"
      tags = ["postgres", "database"]
      port = "5432"
      connect {
        sidecar_service {}
      }
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres:17"
        # intended for maintenance
        #command = "/bin/bash"
        #args = [
        #  "-c",
        #  "sleep infinity"
        #]
      }
      env {
          POSTGRES_USER="${postgres_user}"
          POSTGRES_PASSWORD="${postgres_password}"
          POSTGRES_HOST_AUTH_METHOD="md5"
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
      }
    }
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

  }

  group "pgadmin4" {
    count = 1

    network {
      mode = "bridge"
      port "ui" {
        to = 5050
      }
    }


    service {
      name = "pgadmin"
      port = "ui"
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

    task "pgadmin4" {
      driver = "docker"
      config {
        image = "dpage/pgadmin4"
        volumes = [
          "local/servers.json:/servers.json",
          "local/servers.passfile:/root/.pgpass"
        ]

      }
      template {
        perms = "600"
        change_mode = "noop"
        destination = "local/servers.passfile"
        data = <<EOH
postgres.service.consul:5432:${postgres_database}:${postgres_user}:${postgres_password}
EOH
      }
      template {
        change_mode = "noop"
        destination = "local/servers.json"
        data = <<EOH
{
  "Servers": {
    "1": {
      "Name": "Local Server",
      "Group": "Server Group 1",
      "Port": 5432,
      "Username": "postgres",
      "PassFile": "/root/.pgpass",
      "Host": "localhost",
      "SSLMode": "disable",
      "MaintenanceDB": "postgres"
    }
  }
}
EOH
      }
      env {
        PGADMIN_DEFAULT_EMAIL="${pgadmin_email}"
        PGADMIN_DEFAULT_PASSWORD="${pgadmin_password}"
        PGADMIN_LISTEN_PORT="5050"
        PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION="False"
        PGADMIN_SERVER_JSON_FILE="/servers.json"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = 250
        memory = 256
      }
      service {
        name = "pgadmin-internal"
        tags = [ "urlprefix-/pgadmin strip=/pgadmin"]
        port = "ui"

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
