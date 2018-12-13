data "ignition_systemd_unit" "nomad_client" {
  name    = "nomad-client.service"
  content = "${file("${path.module}/files/nomad-client.service")}"
}

data "ignition_systemd_unit" "consul_client" {
  name    = "consul-client.service"
  content = "${file("${path.module}/files/consul-client.service")}"
}

data "ignition_systemd_unit" "token_refresher" {
  name    = "token-refresher.service"
  content = "${file("${path.module}/files/token-refresher.service")}"
}

data "ignition_systemd_unit" "token_refresher_timer" {
  name    = "token-refresher.timer"
  content = "${file("${path.module}/files/token-refresher.timer")}"
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
  path       = "/etc/systemd/resolved.conf"
  filesystem = "root"
  mode       = 420

  content {
    content = "[Resolve]\nDNS=${var.docker_ip}"
  }
}

data "ignition_file" "docker_conf" {
  path       = "/etc/systemd/system/docker.service.d/10-extra.conf"
  filesystem = "root"
  mode       = 420

  content {
    content = <<-EOF
      [Service]
      Environment="DOCKER_OPTS=--bip ${var.docker_ip}/${var.docker_subnet}"
    EOF
  }
}

data "ignition_file" "gen_nomad_conf" {
  path       = "/opt/gen_nomad_conf.sh"
  filesystem = "root"
  mode       = 493

  content {
    content = "${file("${path.module}/files/gen_nomad_conf.sh")}"
  }
}

data "ignition_file" "gen_consul_conf" {
  path       = "/opt/gen_consul_conf.sh"
  filesystem = "root"
  mode       = 493

  content {
    content = "${data.template_file.gen_consul_conf.rendered}"
  }
}

data "template_file" "consul_acl" {
  template = <<-EOF
  ,"acl_datacenter": "dc1",
  "acl_default_policy": "deny",
  "acl_down_policy": "extend-cache",
  "acl_token": "$${token}"
  EOF

  vars {
    token = "${var.consul_acl_client_token}"
  }
}

data "template_file" "nomad_acl" {
  template = <<-EOF
  consul {
    token = "$${token}"
  }
  EOF

  vars {
    token = "${var.consul_acl_client_token}"
  }
}

data "template_file" "gen_consul_conf" {
  template = "${file("${path.module}/files/gen_consul_conf.sh")}"

  vars {
    master_instance_name = "${var.master_instance_name}"
    docker_ip            = "${var.docker_ip}"
    acl                  = "${var.consul_acl_enable ? data.template_file.consul_acl.rendered : ""}"
  }
}

data "ignition_filesystem" "extra_fs" {
  count = "${length(var.extra_fs)}"
  name  = "extra${count.index}"

  mount {
    device = "${element(var.extra_fs, count.index)}"
    format = "ext4"
  }
}

data "ignition_systemd_unit" "extra_fs" {
  count = "${length(var.extra_fs)}"
  name  = "data${count.index}.mount"

  content = <<-EOF
  [Mount]
  What=${element(var.extra_fs, count.index)}
  Where=/data${count.index}
  Type=ext4

  [Install]
  WantedBy=local-fs.target
  EOF
}

data "ignition_systemd_unit" "swap" {
  count = "${var.swap_size != "0" ? 1 : 0}"
  name  = "var-vm-swapfile1.swap"

  content = <<-EOF
  [Unit]
  Description=Turn on swap
  Requires=create-swapfile.service
  After=create-swapfile.service

  [Swap]
  What=/var/vm/swapfile1

  [Install]
  WantedBy=multi-user.target
  EOF
}

data "ignition_systemd_unit" "swap_create" {
  count = "${var.swap_size != "0" ? 1 : 0}"
  name  = "create-swapfile.service"

  content = <<-EOF
  [Unit]
  Description=Create a swapfile
  RequiresMountsFor=/var
  ConditionPathExists=!/var/vm/swapfile1

  [Service]
  Type=oneshot
  ExecStart=/usr/bin/mkdir -p /var/vm
  ExecStart=/usr/bin/fallocate -l ${var.swap_size}m /var/vm/swapfile1
  ExecStart=/usr/bin/chmod 600 /var/vm/swapfile1
  ExecStart=/usr/sbin/mkswap /var/vm/swapfile1
  RemainAfterExit=true
  EOF
}

data "ignition_config" "slave" {
  systemd = [
    "${data.ignition_systemd_unit.nomad_client.id}",
    "${data.ignition_systemd_unit.consul_client.id}",
    "${data.ignition_systemd_unit.token_refresher.id}",
    "${data.ignition_systemd_unit.token_refresher_timer.id}",
    "${data.ignition_systemd_unit.update_engine.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.extra_fs.*.id}",
    "${data.ignition_systemd_unit.swap.*.id}",
    "${data.ignition_systemd_unit.swap_create.*.id}",
  ]

  files = [
    "${data.ignition_file.resolved_conf.id}",
    "${data.ignition_file.docker_conf.id}",
    "${data.ignition_file.gen_nomad_conf.id}",
    "${data.ignition_file.gen_consul_conf.id}",
  ]

  filesystems = [
    "${data.ignition_filesystem.extra_fs.*.id}",
  ]
}
