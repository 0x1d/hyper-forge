variable "mosquitto_config" {}

variable "mosquitto_image" {}

job "mqtt" {
  datacenters = ["terra"]
  type        = "service"


  group "mqtt" {
    count = 1 

    network {
      mode = "bridge"
      port "mosquitto" {
        to = "1883"
      }
    }
    service {
      name = "mqtt-tcp"
      tags = ["mqtt"]
      port = "1883"
      connect {
        sidecar_service {}
      }
    }

    task "mosquitto" {
      driver = "docker"

      template {
        destination = "local/mosquitto.conf"
        data = var.mosquitto_config
      }

      config {
        image = var.mosquitto_image
        volumes = [
          "local/mosquitto.conf:/mosquitto/config/mosquitto.conf"
        ]
      }

      env {
        TZ = "Europe/Zurich"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}


