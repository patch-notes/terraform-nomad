data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*-hvm"]
  }
}

resource "aws_autoscaling_group" "nomad_masters" {
  count = "${var.num_masters != 0 ? 1 : 0}"

  availability_zones        = ["${var.availability_zones}"]
  name                      = "${var.instance_name}"
  max_size                  = "${var.num_masters}"
  min_size                  = "${var.num_masters}"
  health_check_grace_period = 300
  desired_capacity          = "${var.num_masters}"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.nomad_masters.name}"
  vpc_zone_identifier       = ["${var.subnet_masters_id}"]

  tag {
    key                 = "Name"
    value               = "${var.instance_name}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "nomad_masters" {
  count = "${var.num_masters != 0 ? 1 : 0}"

  name_prefix                 = "${var.instance_name}"
  image_id                    = "${data.aws_ami.coreos.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  security_groups             = ["${var.security_groups}"]
  enable_monitoring           = false
  iam_instance_profile        = "${var.instance_profile}"

  user_data = "${module.config.rendered}"

  lifecycle {
    create_before_destroy = true
    ignore_changes = ["image_id"]
  }
}

module "config" {
  source      = "../config"
  num_masters = "${var.num_masters}"
  instance_name = "${var.instance_name}"
  consul_acl_enable = "${var.consul_acl_enable}"
  consul_acl_master_token = "${var.consul_acl_master_token}"
}
