job "authelia" {
  region = "global"

  datacenters = ["terra"]

  type = "service"

  group "authelia" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = 9091
      }
    }
    
    service {
        name = "authelia"
        port = "http"
    }


    task "web" {
      driver = "docker"

      config {
        image = "authelia/authelia:${version}"
        #network_mode = "host"
        args = [
          "--config",
          "/local/configuration.yml",
        ]
      }
        service {
            name = "authelia-internal"
            port = "http"
            tags = [
                "traefik.enable=true",
                "traefik.http.routers.authelia.rule=Host(`${domain}`)",
                "traefik.http.routers.authelia.tls=true",
                "traefik.http.routers.authelia.tls.certresolver=hetzner",
                "traefik.http.middlewares.authelia.forwardAuth.authResponseHeaders=Remote-User, Remote-Groups, Remote-Name, Remote-Email",
                "traefik.http.middlewares.authelia.forwardAuth.address=https://${domain}/api/authz/forward-auth",
                "traefik.http.middlewares.authelia.forwardAuth.trustForwardHeader=true",
            ]
        }
      template {
        data = <<-EOF
        ###############################################################
        #                   Authelia configuration                    #
        ###############################################################

        jwt_secret: ${jwt_secret}

        server:
          address: 'tcp4://:9091'

        log:
          level: info

        totp:
          disable: true

        authentication_backend:
          ldap:
            address: '${ldap_address}'
            implementation: 'custom'
            timeout: '5s'
            start_tls: false
            tls:
              server_name: 'nas'
              skip_verify: true
              minimum_version: 'TLS1.2'
            base_dn: 'dc=dcentral,dc=systems'
            additional_users_dn: 'cn=users'
            users_filter: '(&({username_attribute}={input}))'
            additional_groups_dn: 'cn=groups'
            groups_filter: '(cn=users)'
            user: 'uid=root,cn=users,dc=dcentral,dc=systems'
            password: "${ldap_password}"
            attributes:
              distinguished_name: 'distinguishedName'
              username: 'uid'
              mail: 'mail'
              member_of: 'memberOf'
              group_name: 'cn'

        access_control:
          default_policy: deny
          rules:
            # Rules applied to everyone
            - domain: "*.dcentral.systems"
              policy: one_factor
              subject:
               - "group:users"

        session:
          name: authelia_session
          # This secret can also be set using the env variables AUTHELIA_SESSION_SECRET_FILE
          secret: ${session_secret};
          expiration: 36000  # 10 hours
          inactivity: 3600  # 1 hour
          cookies:
            - domain: 'dcentral.systems'
              authelia_url: 'https://${domain}'

          # redis:
          #   host: redis
          #   port: 6379
          #   # This secret can also be set using the env variables AUTHELIA_SESSION_REDIS_PASSWORD_FILE
          #   # password: authelia

        regulation:
          max_retries: 3
          find_time: 120
          ban_time: 300

        storage:
          encryption_key: ${storage_encryption_key}
          local:
            path: /config/db.sqlite3
          #postgres:
          #  host: postgres.service.consul
          #  port: 5432
          #  database: authelia
          #  schema: public
          #  username: admin
          #  password: jbc983c@#C@morie
          #  ssl:
          #    mode: disable

        notifier:
          disable_startup_check: false
          filesystem:
            filename: '/config/notification.txt'

        EOF

        destination = "local/configuration.yml"
        env         = false
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }

  }
}