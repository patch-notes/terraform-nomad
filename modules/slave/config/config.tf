data "ignition_systemd_unit" "nomad_client" {
  name    = "nomad-client.service"
  content = "${file("${path.module}/nomad-client.service")}"
}

data "ignition_systemd_unit" "consul_client" {
  name    = "consul-client.service"
  content = "${data.template_file.consul_client_service.rendered}"
}

data "template_file" "consul_client_service" {
  template = "${file("${path.module}/consul-client.service")}"

  vars {
    master_instance_name = "${var.master_instance_name}"
    docker_ip = "${var.docker_ip}"
  }
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

data "ignition_file" "resolved_conf" {
  path = "/etc/systemd/resolved.conf"
  filesystem = "root"
  mode = 420
  content {
    content = "[Resolve]\nDNS=${var.docker_ip}"
  }
}

data "ignition_file" "docker_conf" {
  path = "/etc/systemd/system/docker.service.d/10-extra.conf"
  filesystem = "root"
  mode = 420
  content {
    content =<<-EOF
      [Service]
      Environment="DOCKER_OPTS=--bip ${var.docker_ip}/${var.docker_subnet}"
    EOF
  }
}

data "ignition_file" "gen_nomad_conf" {
  path = "/opt/gen_nomad_conf"
  filesystem = "root"
  mode = 493
  content {
    content = "${file("${path.module}/gen_nomad_conf")}"
  }
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

  files = [
    "${data.ignition_file.resolved_conf.id}",
    "${data.ignition_file.docker_conf.id}",
    "${data.ignition_file.gen_nomad_conf.id}"
  ]
}
