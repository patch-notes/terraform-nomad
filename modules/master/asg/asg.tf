data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*-hvm"]
  }
}

resource "aws_autoscaling_group" "nomad_masters" {
  availability_zones        = ["${var.availability_zones}"]
  name                      = "nomad-master"
  max_size                  = "${var.num_masters}"
  min_size                  = "${var.num_masters}"
  health_check_grace_period = 300
  desired_capacity          = "${var.num_masters}"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.nomad_masters.name}"
  vpc_zone_identifier       = ["${var.subnet_masters_id}"]

  tag {
    key                 = "Name"
    value               = "nomad-master"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "nomad_masters" {
  name_prefix                 = "nomad-master"
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
  }
}

module "config" {
  source      = "../config"
  num_masters = "${var.num_masters}"
}
