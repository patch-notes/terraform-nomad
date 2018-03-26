data "ignition_systemd_unit" "nomad_client" {
  name    = "nomad-client.service"
  content = "${file("${path.module}/nomad-client.service")}"
}

data "ignition_systemd_unit" "consul_client" {
  name    = "consul-client.service"
  content = "${file("${path.module}/consul-client.service")}"
}

data "ignition_systemd_unit" "token_refresher" {
  name    = "token-refresher.service"
  content = "${file("${path.module}/token-refresher.service")}"
}

data "ignition_systemd_unit" "token_refresher_timer" {
  name    = "token-refresher.timer"
  content = "${file("${path.module}/token-refresher.timer")}"
}

data "ignition_systemd_unit" "update_engine" {
  name = "update-engine.service"
  mask = true
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "ignition_config" "slave" {
  systemd = [
    "${data.ignition_systemd_unit.nomad_client.id}",
    "${data.ignition_systemd_unit.consul_client.id}",
    "${data.ignition_systemd_unit.token_refresher.id}",
    "${data.ignition_systemd_unit.token_refresher_timer.id}",
    "${data.ignition_systemd_unit.update_engine.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
  ]
}
