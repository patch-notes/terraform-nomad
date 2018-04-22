data "ignition_systemd_unit" "update_engine" {
  name = "update-engine.service"
  mask = true
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "template_file" "nomad_server" {
  template = "${file("${path.module}/files/nomad-server.service")}"

  vars {
    num_masters = "${var.num_masters}"
    consul_token = "${var.consul_acl_enable ? data.template_file.nomad_acl.rendered : ""}"
  }
}

data "template_file" "nomad_acl" {
  template = "-consul-token=$${acl_master_token}"
  vars {
    acl_master_token = "${var.consul_acl_master_token}"
  }
}
data "template_file" "gen_consul_conf" {
  template = "${file("${path.module}/files/gen_consul_conf.sh")}"

  vars {
    num_masters = "${var.num_masters}"
    instance_name = "${var.instance_name}"
    acl = "${var.consul_acl_enable ? data.template_file.consul_acl.rendered : ""}"
  }
}

data "template_file" "consul_acl" {
  template = <<-EOF
  ,"acl_datacenter": "dc1",
  "acl_master_token": "$${acl_master_token}",
  "acl_default_policy": "deny",
  "acl_down_policy": "extend-cache"
  EOF

  vars {
    acl_master_token = "${var.consul_acl_master_token}"
  }
}

data "ignition_file" "gen_consul_conf" {
  path = "/opt/gen_consul_conf.sh"
  filesystem = "root"
  mode = 493
  content {
    content = "${data.template_file.gen_consul_conf.rendered}"
  }
}

data "ignition_systemd_unit" "nomad_server" {
  name    = "nomad-server.service"
  content = "${data.template_file.nomad_server.rendered}"
}

data "ignition_systemd_unit" "consul_server" {
  name    = "consul-server.service"
  content = "${file("${path.module}/files/consul-server.service")}"
}

data "ignition_config" "nomad_master" {
  systemd = [
    "${data.ignition_systemd_unit.nomad_server.id}",
    "${data.ignition_systemd_unit.consul_server.id}",
    "${data.ignition_systemd_unit.update_engine.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
  ]

  files = [
    "${data.ignition_file.gen_consul_conf.id}",
  ]
}
