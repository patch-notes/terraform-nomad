data "ignition_systemd_unit" "update_engine" {
  name = "update-engine.service"
  mask = true
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "template_file" "nomad_server" {
  template = "${file("${path.module}/nomad-server.service")}"

  vars {
    num_masters = "${var.num_masters}"
  }
}

data "template_file" "consul_server" {
  template = "${file("${path.module}/consul-server.service")}"

  vars {
    num_masters = "${var.num_masters}"
  }
}

data "ignition_systemd_unit" "nomad_server" {
  name    = "nomad-server.service"
  content = "${data.template_file.nomad_server.rendered}"
}

data "ignition_systemd_unit" "consul_server" {
  name    = "consul-server.service"
  content = "${data.template_file.consul_server.rendered}"
}

data "ignition_config" "nomad_master" {
  systemd = [
    "${data.ignition_systemd_unit.nomad_server.id}",
    "${data.ignition_systemd_unit.consul_server.id}",
    "${data.ignition_systemd_unit.update_engine.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
  ]
}
