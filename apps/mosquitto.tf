resource "nomad_job" "mosquitto" {
  jobspec = file("${path.module}/jobs/mosquitto.hcl")
  hcl2 {
    vars = {
      mosquitto_config = file("${path.module}/jobs/config/mosquitto/mosquitto.conf")
      mosquitto_image  = "eclipse-mosquitto:2.0.20"
    }
  }
}
